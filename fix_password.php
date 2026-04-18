<?php
// ============================================================
// fix_password.php
// Place this in C:\xampp\htdocs\lost-knowledge\
// Visit: http://localhost/lost-knowledge/fix_password.php
// DELETE THIS FILE after it works!
// ============================================================

require_once __DIR__ . '/config/db.php';

$password  = 'Admin@1234';
$hash      = password_hash($password, PASSWORD_BCRYPT, ['cost' => 12]);

echo "<h2>Password Fix Tool</h2>";
echo "<p>Generated hash: <code>" . htmlspecialchars($hash) . "</code></p>";

// Test the hash works
$verify = password_verify($password, $hash);
echo "<p>Hash verify test: " . ($verify ? "<strong style='color:green'>PASS ✅</strong>" : "<strong style='color:red'>FAIL ❌</strong>") . "</p>";

try {
    $pdo = get_pdo();

    // Check if admin exists
    $check = $pdo->prepare("SELECT id, email, password FROM users WHERE email = ?");
    $check->execute(['admin@lostknowledge.local']);
    $admin = $check->fetch();

    if ($admin) {
        // Update existing admin
        $update = $pdo->prepare("UPDATE users SET password = ? WHERE email = ?");
        $update->execute([$hash, 'admin@lostknowledge.local']);
        echo "<p style='color:green'><strong>✅ Admin password updated successfully!</strong></p>";
        echo "<p>Old hash was: <code>" . htmlspecialchars($admin['password']) . "</code></p>";

        // Verify the update worked
        $recheck = $pdo->prepare("SELECT password FROM users WHERE email = ?");
        $recheck->execute(['admin@lostknowledge.local']);
        $newRow = $recheck->fetch();
        $finalVerify = password_verify('Admin@1234', $newRow['password']);
        echo "<p>Final verify test: " . ($finalVerify ? "<strong style='color:green'>PASS ✅ Login will work!</strong>" : "<strong style='color:red'>FAIL ❌</strong>") . "</p>";

    } else {
        // Insert admin user fresh
        $insert = $pdo->prepare(
            "INSERT INTO users (username, email, password, role) VALUES (?, ?, ?, ?)"
        );
        $insert->execute(['admin', 'admin@lostknowledge.local', $hash, 'admin']);
        echo "<p style='color:green'><strong>✅ Admin user created fresh!</strong></p>";
    }

    echo "<hr>";
    echo "<h3>All users in database:</h3>";
    $all = $pdo->query("SELECT id, username, email, role, created_at FROM users")->fetchAll();
    echo "<table border='1' cellpadding='6'>";
    echo "<tr><th>ID</th><th>Username</th><th>Email</th><th>Role</th><th>Created</th></tr>";
    foreach ($all as $u) {
        echo "<tr>";
        echo "<td>" . $u['id'] . "</td>";
        echo "<td>" . htmlspecialchars($u['username']) . "</td>";
        echo "<td>" . htmlspecialchars($u['email']) . "</td>";
        echo "<td>" . htmlspecialchars($u['role']) . "</td>";
        echo "<td>" . $u['created_at'] . "</td>";
        echo "</tr>";
    }
    echo "</table>";

} catch (Exception $e) {
    echo "<p style='color:red'><strong>DB Error: " . htmlspecialchars($e->getMessage()) . "</strong></p>";
    echo "<p>Make sure your database is set up and config/db.php has the right credentials.</p>";
}

echo "<hr><p style='color:red'><strong>⚠️ DELETE this file after use!</strong></p>";
?>
