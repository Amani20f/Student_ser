<?php

namespace App\Console\Commands;

use App\Models\User;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Hash;

class CreateAdminUser extends Command
{
    /**
     * The name and signature of the console command.
     *
     * Set ADMIN_EMAIL, ADMIN_USERNAME, and ADMIN_SEED_PASSWORD in your .env
     * before running, or the command will use the defaults below and prompt
     * you to confirm.
     */
    protected $signature = 'app:create-admin
                            {--email= : Admin email (defaults to ADMIN_EMAIL env var)}
                            {--username= : Admin username (defaults to ADMIN_USERNAME env var)}
                            {--name= : Admin display name}';

    /**
     * The console command description.
     */
    protected $description = 'Create or update the system admin user and assign the admin role';

    /**
     * Execute the console command.
     */
    public function handle(): int
    {
        $email    = $this->option('email')
            ?? env('ADMIN_EMAIL', 'admin@university.edu');
        $username = $this->option('username')
            ?? env('ADMIN_USERNAME', 'admin');
        $name     = $this->option('name')
            ?? env('ADMIN_NAME', 'System Admin');
        $password = env('ADMIN_SEED_PASSWORD', 'change-me');

        if ($password === 'change-me') {
            $this->warn('ADMIN_SEED_PASSWORD is not set in .env — using the default "change-me". Please change it immediately after setup.');
        }

        $this->info("Creating admin user: {$email}");

        $user = User::firstOrCreate(
            ['email' => $email],
            [
                'name'              => $name,
                'username'          => $username,
                'password'          => Hash::make($password),
                'role'              => 'admin',
                'email_verified_at' => now(),
            ]
        );

        $user->assignRole('admin');

        $this->info("✓ Admin user ready.");
        $this->line("  Email   : {$email}");
        $this->line("  Username: {$username}");

        if ($password !== 'change-me') {
            $this->line("  Password: (set via ADMIN_SEED_PASSWORD env var)");
        } else {
            $this->warn("  Password: change-me  ← CHANGE THIS IMMEDIATELY");
        }

        return Command::SUCCESS;
    }
}
