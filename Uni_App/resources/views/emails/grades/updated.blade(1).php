<x-mail::message>
# Grade Update Notification 🎓

Hello {{ $grade->student->user->name }},

Your grade for the course **{{ $grade->course->name }}** ({{ $grade->course->code }}) has been updated.

**Performance Summary:**
- **Semester:** {{ $grade->semester->name }}
- **First Exam:** {{ $grade->first ?? 'N/A' }}
- **Midterm:** {{ $grade->midterm ?? 'N/A' }}
- **Final Exam:** {{ $grade->final ?? 'N/A' }}
- **Total Grade:** **{{ $grade->total_grade ?? 'N/A' }}**

You can view your full academic transcript in the student portal.

<x-mail::button :url="config('app.url') . '/dashboard/grades'">
Check Grades
</x-mail::button>

Thanks,<br>
{{ config('app.name') }} Academic Office
</x-mail::message>
