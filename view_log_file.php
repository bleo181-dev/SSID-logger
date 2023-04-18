<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>Log file viewer</title>
	<style>
		table {
			border-collapse: collapse;
			margin: 0 auto;
			font-family: Arial, Helvetica, sans-serif;
			font-size: 14px;
			line-height: 1.4;
		}

		th, td {
			padding: 10px;
			text-align: center;
			border: 1px solid #ddd;
		}

		th {
			background-color: #f2f2f2;
		}

		tr:hover {
			background-color: #f5f5f5;
		}

		caption {
			margin-bottom: 20px;
			font-weight: bold;
			font-size: 16px;
			text-align: left;
			background-color: #ddd;
			padding: 10px;
			border: 1px solid #ddd;
		}
	</style>
</head>
<body>
    <?php
        // Name of the Wi-Fi networks log file
$log_file = "log_wifi.txt";

// Check if the log file exists
if (!file_exists($log_file)) {
    die("Log file does not exist.");
}

$log_content = file_get_contents($log_file); // read the content of the log file

// split the content based on the log entry separator
$log_entries = explode('-------- +', $log_content);

// get only the last set of log entries
$last_log_entry = end($log_entries);

// loop through the log lines and extract the SSID data
$ssid_data = array();
foreach (explode("\n", $last_log_entry) as $log_entry) {
    if (strpos($log_entry, "SSID: ") === 0) {
        $line_parts = preg_split('/ -#- Last seen: | -#- Total time: /', $log_entry);
        $ssid_name = str_replace("SSID: ", "", $line_parts[0]);
        $last_seen = $line_parts[1];
        $total_time = $line_parts[2];
        $ssid_data[] = array(
            "ssid_name" => $ssid_name,
            "last_seen" => $last_seen,
            "total_time" => $total_time
        );
    }
}

// sort the SSID data by the total time
usort($ssid_data, function($a, $b) {
    $a_total_time = strtotime($a["total_time"]);
    $b_total_time = strtotime($b["total_time"]);
    if ($a_total_time == $b_total_time) {
        return 0;
    } else {
        return ($a_total_time < $b_total_time) ? -1 : 1;
    }
});

// print the SSID data as a table
echo '<table>';
echo '<caption>Wi-Fi networks log</caption>';
echo '<thead><tr><th>SSID Name</th><th>Last Seen</th><th>Total Time</th></tr></thead>';
echo '<tbody>';
foreach ($ssid_data as $ssid) {
    echo '<tr><td>' . $ssid["ssid_name"] . '</td><td>' . $ssid["last_seen"] . '</td><td>' . $ssid["total_time"] . '</td></tr>';
}
echo '</tbody>';
echo '</table>';

    ?>
 
    </body>
    </html>