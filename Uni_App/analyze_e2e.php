<?php
$json = file_get_contents('e2e_results.json');
$data = json_decode($json, true);

foreach ($data as $workflow => $result) {
    echo "Workflow: $workflow\n";
    echo "Status: " . $result['status'] . "\n";
    
    if ($result['status'] !== 200 && $result['status'] !== 201) {
        echo "Error Content: " . substr(json_encode($result['content']), 0, 500) . "\n";
    } else {
        $content = $result['content'];
        $firstItem = null;
        if (isset($content['data']) && is_array($content['data'])) {
            if (array_is_list($content['data'])) {
                $firstItem = $content['data'][0] ?? null;
            } else {
                // Associative array, e.g. grades structured by semester
                $firstKey = array_key_first($content['data']);
                if (is_array($content['data'][$firstKey])) {
                    if (array_is_list($content['data'][$firstKey])) {
                        $firstItem = $content['data'][$firstKey][0] ?? null;
                    } else {
                        $firstItem = $content['data'][$firstKey];
                    }
                } else {
                    $firstItem = $content['data'];
                }
            }
        }
        
        if ($firstItem) {
            echo "Keys: " . implode(', ', array_keys($firstItem)) . "\n";
        } else {
            echo "Keys: (empty data)\n";
        }
    }
    echo "---------------------------\n";
}
