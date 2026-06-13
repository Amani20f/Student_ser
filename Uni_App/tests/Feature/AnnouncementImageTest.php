<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;
use App\Models\User;
use App\Models\Announcement;

class AnnouncementImageTest extends TestCase
{
    use RefreshDatabase;

    public function test_announcement_image_flow()
    {
        Storage::fake('public');
        $this->withoutMiddleware();

        $admin = User::factory()->create(['role' => 'admin']);
        $token = $admin->createToken('test')->plainTextToken;
        $headers = ['Authorization' => 'Bearer ' . $token, 'Accept' => 'application/json'];

        // 1. Create without image
        $response1 = $this->postJson('/api/admin/announcements', [
            'title' => 'No Image',
            'content' => 'Content without image',
            'target_audience' => 'all_students'
        ], $headers);
        $response1->dump();
        $response1->assertStatus(201);
        $id1 = $response1->json('id');

        // 2. Create with image
        $file1 = UploadedFile::fake()->image('test1.jpg');
        $response2 = $this->post('/api/admin/announcements', [
            'title' => 'With Image',
            'content' => 'Content with image',
            'target_audience' => 'all_students',
            'image' => $file1
        ], $headers);
        $response2->assertStatus(201);
        $id2 = $response2->json('id');
        $imagePath2 = Announcement::find($id2)->image_path;
        Storage::disk('public')->assertExists($imagePath2);

        // 3. Update without image
        $response3 = $this->post('/api/admin/announcements/' . $id1, [
            '_method' => 'PUT',
            'title' => 'No Image Updated',
            'content' => 'Content without image updated',
            'target_audience' => 'all_students',
        ], $headers);
        $response3->assertStatus(200);

        // 4. Update replacing image
        $file2 = UploadedFile::fake()->image('test2.jpg');
        $response4 = $this->post('/api/admin/announcements/' . $id2, [
            '_method' => 'PUT',
            'title' => 'With Image Updated',
            'content' => 'Content with image updated',
            'target_audience' => 'all_students',
            'image' => $file2
        ], $headers);
        $response4->assertStatus(200);
        Storage::disk('public')->assertMissing($imagePath2); // Old image deleted
        $imagePath4 = Announcement::find($id2)->image_path;
        Storage::disk('public')->assertExists($imagePath4); // New image exists

        // 5. Delete with image
        $response5 = $this->delete('/api/admin/announcements/' . $id2, [], $headers);
        $response5->assertStatus(204);
        Storage::disk('public')->assertMissing($imagePath4); // Image deleted on destroy
        
        echo "All tests passed successfully!\n";
    }
}
