from fastapi import FastAPI, UploadFile, File, HTTPException, BackgroundTasks
from fastapi.responses import HTMLResponse, FileResponse
import subprocess, uuid, shutil
from pathlib import Path
from typing import List

app = FastAPI()
JOBS_DIR = Path("/jobs")
JOBS_DIR.mkdir(exist_ok=True)
jobs = {}

NEXTFLOW_CONFIG = """
docker {
    enabled    = true
    runOptions = '--platform linux/amd64'
}
"""

@app.get("/", response_class=HTMLResponse)
async def index():
    with open("/app/static/index.html") as f:
        return f.read()

@app.post("/run")
async def run_workflow(
    background_tasks: BackgroundTasks,
    workflow: UploadFile = File(...),
    data: List[UploadFile] = File(default=[])
):
    job_id = str(uuid.uuid4())[:8]
    job_dir = JOBS_DIR / job_id
    job_dir.mkdir()

    workflow_path = job_dir / workflow.filename
    with open(workflow_path, "wb") as f:
        f.write(await workflow.read())

    for d in data:
        if d.filename:
            with open(job_dir / d.filename, "wb") as f:
                f.write(await d.read())

    # Se è un .nf e l'utente non ha caricato un nextflow.config, lo generiamo noi
    if workflow.filename.endswith(".nf") and not (job_dir / "nextflow.config").exists():
        with open(job_dir / "nextflow.config", "w") as f:
            f.write(NEXTFLOW_CONFIG)

    jobs[job_id] = {"status": "running", "log": "", "workflow": workflow.filename, "has_results": False}
    background_tasks.add_task(execute_workflow, job_id, job_dir, workflow_path)
    return {"job_id": job_id}

def execute_workflow(job_id, job_dir, workflow_path):
    filename = workflow_path.name
    if filename.endswith(".nf"):
        cmd = ["nextflow", "run", str(workflow_path), "-work-dir", str(job_dir / "work")]
    elif filename.endswith((".yml", ".yaml")):
        cmd = ["streamflow", "run", str(workflow_path)]
    else:
        jobs[job_id]["status"] = "error"
        jobs[job_id]["log"] = f"Tipo file non supportato: {filename}"
        return
    try:
        result = subprocess.run(cmd, cwd=str(job_dir), capture_output=True, text=True, timeout=7200)
        jobs[job_id]["log"] = result.stdout + "\n" + result.stderr
        if result.returncode == 0:
            jobs[job_id]["status"] = "done"
            shutil.make_archive(str(job_dir / "results_archive"), "zip", str(job_dir))
            jobs[job_id]["has_results"] = True
        else:
            jobs[job_id]["status"] = "error"
    except subprocess.TimeoutExpired:
        jobs[job_id]["status"] = "error"
        jobs[job_id]["log"] = "Timeout dopo 2 ore."
    except Exception as e:
        jobs[job_id]["status"] = "error"
        jobs[job_id]["log"] = str(e)

@app.get("/status/{job_id}")
async def get_status(job_id: str):
    if job_id not in jobs:
        raise HTTPException(status_code=404)
    return jobs[job_id]

@app.get("/download/{job_id}")
async def download(job_id: str):
    if job_id not in jobs or not jobs[job_id].get("has_results"):
        raise HTTPException(status_code=404)
    return FileResponse(JOBS_DIR / job_id / "results_archive.zip", filename=f"results_{job_id}.zip")

@app.get("/jobs")
async def list_jobs():
    return [{"job_id": k, **v} for k, v in jobs.items()]
