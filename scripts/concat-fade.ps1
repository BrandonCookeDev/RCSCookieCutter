# Batch file to fade in and out two videos together with ffmpeg
# $1 resolution [1280x720, 1920x1080, etc]
# $2 fade duration in seconds
# $3 output file name
# $4 video 1 path
# $5 video 1 duration in HH:MM:SS
# $6 video 2 path
# $7 video 2 duration in HH:MM:SS

function get_duration{
    try{
        $vid_path = $args[0]
        $probe_cmd = "ffprobe -i `"$vid_path`" -show_entries `"stream=codec_type,duration`" -of `"compact=p=0:nk=1`""
        write-host $probe_cmd
        
        [string]$output = $(iex $probe_cmd)
        write-host $output
        $split = $output.Split(" ")
        $seconds = $split[0].Split('|')[1].Trim()
        return $seconds
        
        $duration_line = ""
        foreach($line in $split){
            if($line -Contains "Duration"){
                $duration_line = $line
                break
            }
        }
        
        if($duration_line -eq ""){
            echo "No duration found"
            exit(1)
        }
        else{
            [int]$dur = $duration_line.Split(',')[0].Split(':')[1].Trim()
            echo $dur
            return $dur
        }
    }
    catch{
        write-host 'Error getting duration'
        exit(1)
    }
}

function convert_hhmmss_to_seconds{
    $stamp = $args[0]
    $split = $stamp.Split(':')
    $minutes = 0
    $seconds = 0
    
    [int]$hh = $split[0]
    [int]$mm = $split[1]
    [int]$ss = $split[2]
    
    #Count hours in minutes
    if( $hh -gt 0 ){
        $minutes += $split[0] * 60
    }
    
    #Count minutes
    if( $mm -gt 0 ){
        $minutes += $mm
    }
    
    #Convert minutes
    $seconds += $minutes * 60
    
    #Add remaining seconds
    $seconds += $ss
    
    return $seconds
    
}

#####################################
##                                 ## 
## START MAIN                      ##
##                                 ##
#####################################

if ($args.Count -lt 7){
    echo 'USAGE concat-fade.ps1 resolution fade_duration out_file_path video1_path video1_duration_frames video2_path video2_duration_frames'
    exit(1)
}
else{
    echo "Got args $args"
}

$res           = $args[0]
$fade_dur      = $args[1]
$out_file      = $args[2]
$v1_path       = $args[3]
$v1_dur_hhmmss = $args[4]
$v2_path       = $args[5]
$v2_dur_hhmmss = $args[6]

$dur1 = get_duration($v1_path)
$dur2 = get_duration($v2_path)
$v1_dur = $dur1
$v2_dur = $dur2
$total_dur = [decimal]$v1_dur+[decimal]$v2_dur-[decimal]$fade_dur
#$v1_dur = convert_hhmmss_to_seconds($dur1)
#$v2_dur = convert_hhmmss_to_seconds($dur2)

$cmd = "ffmpeg -i `"$v1_path`" -i `"$v2_path`" ``
-filter_complex ``
`"color=black:$($res):d=$($total_dur)[base]; ``
 [0:v]setpts=PTS-STARTPTS[v0]; ``
 [1:v]format=yuva420p,fade=in:st=0:d=$fade_dur.000:alpha=1, ``
      setpts=PTS-STARTPTS+(($($v1_dur-$fade_dur))/TB)[v1]; ``
 [base][v0]overlay[tmp]; ``
 [tmp][v1]overlay,format=yuv420p[fv]; ``
 [0:a][1:a]acrossfade=d=$fade_dur[fa]`" ``
-map [fv] -map [fa] ``
$out_file"

echo $cmd

iex $cmd

