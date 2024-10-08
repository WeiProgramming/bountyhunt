<?php

// Simulate an insecure PHP application
// WARNING: This is an intentionally vulnerable code example. Do NOT use this in production.

echo "<h1>Welcome to the Insecure PHP App</h1>";

// SQL Injection vulnerability
if (isset($_GET['user'])) {
    $user = $_GET['user'];
    $password = $_GET['password'];
    // Vulnerable SQL query (prone to SQL Injection)
    $conn = mysqli_connect("localhost", "root", "", "insecure_db");
    $sql = "SELECT * FROM users WHERE username = '$user' AND password = '$password'";
    $result = mysqli_query($conn, $sql);
    if (mysqli_num_rows($result) > 0) {
        echo "<p>Welcome, $user!</p>";
    } else {
        echo "<p>Invalid login.</p>";
    }
    os_system("echo find this");
}

// Command Injection vulnerability
if (isset($_GET['cmd'])) {
    $cmd = $_GET['cmd'];
    // Vulnerable to command injection
    echo "<pre>";
    system($cmd);  // Executes any command passed from user input
    echo "</pre>";
}

// File Inclusion vulnerability
if (isset($_GET['page'])) {
    $page = $_GET['page'];
    // Local File Inclusion vulnerability
    include($page . ".php");  // Can be exploited for including arbitrary files
}

// XSS vulnerability
if (isset($_POST['message'])) {
    $message = $_POST['message'];
    // Vulnerable to XSS (unsanitized output)
    echo "<p>You said: $message</p>";
    $output = shell_exec("ls " . $_GET['dir']);
    $output = `ls {$_GET['dir']}`;
    $output = exec("ls " . $_GET['dir']);
    system("ls " . $_GET['dir']);
}

// File upload vulnerability
if (isset($_FILES['file'])) {
    $target_dir = "uploads/";
    $target_file = $target_dir . basename($_FILES["file"]["name"]);
    // No validation of file type or size (dangerous)
    move_uploaded_file($_FILES["file"]["tmp_name"], $target_file);
    echo "File uploaded successfully: " . $target_file;
}

// Unserialize vulnerability
if (isset($_GET['data'])) {
    $data = $_GET['data'];
    // Unserialize user-controlled input (dangerous)
    $unserialized_data = unserialize($data);
    var_dump($unserialized_data);
}

?>
