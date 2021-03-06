
function get_duration{
    try{
        $vid_path = $args[0]
        $probe_cmd = "ffprobe -i `"$vid_path`" -show_entries `"stream=codec_type,duration,nb_frames`" -of `"compact=p=0:nk=1`""
        write-host $probe_cmd
        
        [string]$output = $(iex $probe_cmd)
        write-host $output
        $split = $output.Split(" ")
        $seconds = $split[0].Split('|')[1].Trim()
        $frames = $split[0].Split('|')[2].Trim();
        return [decimal]$seconds
        
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

if($args.Count -lt 2){
    echo 'USAGE get-frames video_path fps'
    exit(1)
}
else{
    echo "got $args"
}

$video = $args[0]
$fps = $args[1]

$seconds = get_duration($video)
$frames = $($seconds * $fps)
return $frames