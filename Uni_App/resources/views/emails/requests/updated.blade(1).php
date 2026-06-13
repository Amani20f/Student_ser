<x-mail::message>
# Request Status Updated 📋

Hello {{ $request->student->user->name }},

The status of your service request **"{{ $request->type }}"** has been updated to: **{{ strtoupper($request->status) }}**.

**Admin Comment:**
> {{ $request->admin_comment ?? 'No additional comments provided.' }}

@if($request->status === 'approved')
Please follow any instructions provided in the portal to complete the process.
@else
If you have questions regarding this decision, please contact the Student Affairs office.
@endif

<x-mail::button :url="config('app.url') . '/dashboard'">
View Request in Portal
</x-mail::button>

Thanks,<br>
{{ config('app.name') }} Student Affairs
</x-mail::message>
