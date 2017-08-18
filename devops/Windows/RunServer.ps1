################
### LOGGING ####
################

# SET THE LOG FILE
$LOG = "$(Get-Location)\CookieCutterInstall.log"

function log($msg){
    $time = Get-Date
    echo "$time :: $msg" >> $LOG
}

###################
#### VARIABLES ####
###################

log 'Setting Local Variables'

$PROGRAMS_DIR = "C:\Program Files (x86)"
$RCS_PROGRAMS_DIR = "$PROGRAMS_DIR\Recursion"
$RCS_COOKIE_CUTTER_DIR = "$RCS_PROGRAMS_DIR\CookieCutter"

$STARTUP_DIR = "C:\Users\$Env:USERNAME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
$STARTUP_FILE = "$STARTUP_DIR\StartCookieCutter.bat"

## SETUP AND RUN SERVER
log '#### STARTED SERVER FROM RunServer ####'
log "Setting up and running server"
cd $RCS_COOKIE_CUTTER_DIR
npm run-script installAll | Out-File -Filepath $LOG -Append
node server | Out-File -Filepath $LOG -Append