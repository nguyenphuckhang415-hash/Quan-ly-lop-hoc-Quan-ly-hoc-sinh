# QUẢN LÝ HỌC SINH V18 — BẢN TỐI ƯU CHO RENDER

## Có gì khác bản trước?

**Không chỉnh sửa file Python gốc.** Chỉ thay lớp chạy VNC:

- Màn hình ảo từ 1600x900 → 1280x960 để giảm số điểm ảnh phải truyền nhưng vẫn chứa được các cửa sổ phụ cao.
- Bật XKB + keyboard repeat cho bàn phím.
- Tắt một số cơ chế X11 không cần thiết cho remote framebuffer.
- Dùng các encoding phù hợp hơn cho thay đổi màn hình.
- Giảm thời gian chờ framebuffer xuống 3 ms để chuột/nút phản hồi nhanh hơn.
- Websockify lấy cổng từ biến môi trường `PORT` của Render.
- Có trang `/` tự mở noVNC ở chế độ cho phép điều khiển.

## Render

Tạo **Web Service** từ repository có Dockerfile. Render yêu cầu web service lắng nghe trên `0.0.0.0` và cổng được cung cấp qua biến `PORT`; bộ này đã làm đúng phần đó.

### Lưu ý về gói Free

Render cho biết Free Web Service sẽ tự sleep sau 15 phút không có HTTP request hoặc WebSocket message đến dịch vụ; lúc có người truy cập lại sẽ phải khởi động lại. Ngoài ra filesystem của Free là ephemeral nên file SQLite trên máy chủ **không được xem là nơi lưu dữ liệu lâu dài**. Xem tài liệu Render.

Để giữ SQLite mà **không sửa code**, cần dùng Web Service trả phí + Persistent Disk gắn vào `/data`. Hoặc phải chuyển database sang hệ quản trị khác, nhưng việc đó sẽ cần chỉnh code.

## Test

Sau khi deploy, mở URL Render của bạn. Trang `/` sẽ chuyển thẳng vào màn hình V18.

Trên máy tính, bấm vào vùng ứng dụng trước khi gõ. Trên noVNC, nếu thanh điều khiển đang mở, hãy đảm bảo chế độ `View Only` đang tắt.

## File Python

`app/Quan_ly_hoc_sinh_V18(2).py` được giữ nguyên nội dung; không thay đổi màu sắc, font, kích thước, nút bấm hay logic Tkinter.
