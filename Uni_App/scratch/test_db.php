<?php
try {
    $pdo = new PDO('pgsql:host=127.0.0.1;port=5432;dbname=university_system', 'postgres', 'hanan');
    echo "Connected to 'university_system' database successfully!\n";
    
    // Check tables
    $stmt = $pdo->query("SELECT table_name FROM information_schema.tables WHERE table_schema='public'");
    $tables = $stmt->fetchAll(PDO::FETCH_COLUMN);
    echo "Tables in 'university_system':\n";
    if (empty($tables)) {
        echo "No tables found in public schema.\n";
    } else {
        foreach ($tables as $table) {
            echo "- $table\n";
        }
    }
} catch (PDOException $e) {
    echo "Connection failed: " . $e->getMessage() . "\n";
}
