<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head>
    <meta charset="utf-8">
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
    <div style="background-color: #f8f9fa; padding: 20px; border-radius: 8px; text-align: center;">
        <h2 style="color: #2c3e50;">مرحباً بك في الجامعة!</h2>
    </div>
    
    <div style="padding: 20px;">
        <p>عزيزي {{ $application->full_name }}،</p>
        <p>يسعدنا إخبارك بأنه <strong>تم قبول طلب تسجيلك</strong> في الجامعة بنجاح.</p>
        
        <div style="background-color: #e8f4f8; padding: 15px; border-radius: 5px; margin: 20px 0;">
            <h3 style="margin-top: 0; color: #0066cc;">بيانات الحساب الخاص بك:</h3>
            <p><strong>الرقم الجامعي:</strong> {{ $studentNumber }}</p>
            <p><strong>كلمة المرور المؤقتة:</strong> <span style="letter-spacing: 2px; font-weight: bold;">{{ $tempPassword }}</span></p>
        </div>
        
        <p>نرجو منك تسجيل الدخول باستخدام بوابة الطالب الإلكترونية وتغيير كلمة المرور المؤقتة فوراً.</p>
        
        <p style="margin-top: 30px;">مع تمنياتنا لك بالتوفيق والنجاح،<br>إدارة القبول والتسجيل</p>
    </div>
</body>
</html>
