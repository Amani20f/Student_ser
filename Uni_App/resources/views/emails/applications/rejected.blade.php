<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head>
    <meta charset="utf-8">
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
    <div style="background-color: #f8f9fa; padding: 20px; border-radius: 8px; text-align: center;">
        <h2 style="color: #c0392b;">تحديث حالة طلب التسجيل</h2>
    </div>
    
    <div style="padding: 20px;">
        <p>عزيزي {{ $application->full_name }}،</p>
        <p>نشكر لك اهتمامك بالانضمام للجامعة. بعد مراجعة طلب التسجيل الخاص بك (رقم {{ $application->application_number }})، نأسف لإخبارك بأنه <strong>تم رفض الطلب</strong>.</p>
        
        <div style="background-color: #fdf2f2; padding: 15px; border-radius: 5px; margin: 20px 0; border: 1px solid #f5c6cb;">
            <h3 style="margin-top: 0; color: #721c24;">سبب الرفض:</h3>
            <p style="color: #721c24;">{{ $reason }}</p>
        </div>
        
        <p>لأي استفسار، يرجى التواصل مع عمادة القبول والتسجيل أو مراجعتنا.</p>
        
        <p style="margin-top: 30px;">مع تمنياتنا لك بالتوفيق،<br>إدارة القبول والتسجيل</p>
    </div>
</body>
</html>
