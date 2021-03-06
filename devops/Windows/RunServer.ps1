################
### LOGGING ####
################

# SET THE LOG FILE
$LOG = "$(Get-Location)\CookieCutterInstall.log"

function log($msg){
    $time = Get-Date
    echo "$time :: $msg" >> $LOG
}

try{
    ###################
    #### VARIABLES ####
    ###################

    log 'Setting Local Variables'

    $PROGRAMS_DIR = "C:\Program Files (x86)"
    $RCS_PROGRAMS_DIR = "$PROGRAMS_DIR\Recursion"
    $RCS_COOKIE_CUTTER_DIR = "$RCS_PROGRAMS_DIR\CookieCutter"

    $STARTUP_DIR = "C:\Users\$Env:USERNAME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
    $STARTUP_FILE = "$STARTUP_DIR\StartCookieCutter.bat"

    $VIDEOS_DIR = "$RCS_COOKIE_CUTTER_DIR\client\videos"
    $videosDirExists = Test-Path $VIDEOS_DIR

    ## SETUP AND RUN SERVER
    log '#### STARTED SERVER FROM RunServer ####'
    log "Setting up and running server"

    cd C:\
    cd $RCS_COOKIE_CUTTER_DIR
    npm run-script installAll | Out-File -Filepath $LOG -Append
    if(! $videosDirExists){
        log "Creating Videos Directory"
        New-Item $VIDEOS_DIR -Type Directory
    }

    Start-Process -FilePath http://localhost:1337

    node server | Out-File -Filepath $LOG -Append

}
catch{
    log "!!!!!!!!!!!!!!! Failure !!!!!!!!!!!!!!!"
    log $_.Exception.Message
    exit
}