import os, shutil, runpy
DATA='/data'
SRC='/opt/original/Quan_ly_hoc_sinh_V18(2).py'
DST=os.path.join(DATA,'Quan_ly_hoc_sinh_V18(2).py')
os.makedirs(DATA, exist_ok=True)
if not os.path.exists(DST):
    shutil.copy2(SRC, DST)
# Compatibility only; original source is not edited.
if not hasattr(os, 'startfile'):
    def startfile(path):
        import subprocess
        subprocess.Popen(['xdg-open', path], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    os.startfile = startfile
os.chdir(DATA)
runpy.run_path(DST, run_name='__main__')
