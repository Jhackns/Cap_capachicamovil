$body = @{
    name = "Test User"
    email = "test@test.com"
    password = "password123"
    password_confirmation = "password123"
    phone = "987654321"
    country = "Perú"
    birth_date = "1990-01-01"
    address = "Dirección de prueba"
    gender = "Masculino"
    preferred_language = "Español"
} | ConvertTo-Json

Write-Host "Testing register endpoint..."
Write-Host "Body: $body"

try {
    $response = Invoke-WebRequest -Uri "http://192.168.1.64:8000/api/register" -Method POST -Headers @{"Content-Type"="application/json"} -Body $body
    Write-Host "Status Code: $($response.StatusCode)"
    Write-Host "Response: $($response.Content)"
} catch {
    Write-Host "Error: $($_.Exception.Message)"
    Write-Host "Response: $($_.Exception.Response)"
} 