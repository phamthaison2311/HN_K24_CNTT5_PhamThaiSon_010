CREATE DATABASE project_it202;
USE project_it202;

-- PHẦN 1: THIẾT KẾ CSDL & CHÈN DỮ LIỆU
CREATE TABLE Customers(
    Customer_ID VARCHAR(25) PRIMARY KEY,
    Full_Name VARCHAR(50) NOT NULL,
    Phone_Number VARCHAR(11) UNIQUE NOT NULL,
    Email VARCHAR(100),
    Join_Date DATE NOT NULL
);

CREATE TABLE Insurance_Packages(
    Package_ID VARCHAR(25) PRIMARY KEY,
    Package_Name VARCHAR(100) NOT NULL UNIQUE,
    Max_Limit DECIMAL(15,2) NOT NULL CHECK (Max_Limit >= 0),
    Base_Premium DECIMAL(15,2) NOT NULL CHECK (Base_Premium >= 0)
);

CREATE TABLE Policies(
    Policy_ID VARCHAR(25) PRIMARY KEY,
    Customer_ID VARCHAR(25) NOT NULL,
    Package_ID VARCHAR(25) NOT NULL,
    Start_Date DATE NOT NULL,
    End_Date DATE NOT NULL,
    Status VARCHAR(15) NOT NULL,
    CONSTRAINT fk_policies_customer FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID),
    CONSTRAINT fk_policies_package  FOREIGN KEY (Package_ID)  REFERENCES Insurance_Packages(Package_ID),
    CONSTRAINT chk_policy_dates CHECK (End_Date >= Start_Date)
);

CREATE TABLE Claims(
    Claim_ID VARCHAR(25) PRIMARY KEY,
    Policy_ID VARCHAR(25) NOT NULL,
    Claim_Date DATE NOT NULL,
    Claim_Amount DECIMAL(15,2) NOT NULL CHECK (Claim_Amount >= 0),
    Status VARCHAR(15) NOT NULL,
    CONSTRAINT fk_claims_policy FOREIGN KEY (Policy_ID) REFERENCES Policies(Policy_ID)
);

CREATE TABLE Claim_Processing_Log(
    Log_ID VARCHAR(25) PRIMARY KEY,
    Claim_ID VARCHAR(25) NOT NULL,
    Action_Detail TEXT NOT NULL,
    Recorded_At DATETIME NOT NULL,
    Processor VARCHAR(25) NOT NULL,
    CONSTRAINT fk_log_claim FOREIGN KEY (Claim_ID) REFERENCES Claims(Claim_ID)
);

-- Thêm dữ liệu

INSERT INTO Customers(Customer_ID, Full_Name, Phone_Number, Email, Join_Date) VALUES
('C001', 'Nguyen Hoang Long', '0901112223', 'long.nh@gmail.com', '2024-01-15'),
('C002', 'Tran Thi Kim Anh', '0988877766', 'anh.tk@yahoo.com', '2024-03-10'),
('C003', 'Le Hoang Nam', '0903334445', 'nam.lh@outlook.com', '2025-05-20'),
('C004', 'Pham Duc Minh', '0355556667', 'duc.pm@gmail.com', '2025-08-12'),
('C005', 'Hoang Thu Thao', '0779998881', 'thao.ht@gmail.com', '2026-01-01');

INSERT INTO Insurance_Packages(Package_ID, Package_Name, Max_Limit, Base_Premium) 
VALUES
('PKG01', 'Bảo hiểm Sức khỏe Gold', 500000000,  5000000),
('PKG02', 'Bảo hiểm Ô tô Liberty',   1000000000, 15000000),
('PKG03', 'Bảo hiểm Nhân thọ An Bình',2000000000,25000000),
('PKG04', 'Bảo hiểm Du lịch Quốc tế',100000000,  1000000),
('PKG05', 'Bảo hiểm Tai nạn 24/7',   200000000,  2500000);

INSERT INTO Policies(Policy_ID, Customer_ID, Package_ID, Start_Date, End_Date, Status) 
VALUES
('POL101', 'C001', 'PKG01', '2024-01-15', '2025-01-15', 'Expired'),
('POL102', 'C002', 'PKG02', '2024-03-10', '2025-03-10', 'Active'),  
('POL103', 'C003', 'PKG03', '2025-05-20', '2035-05-20', 'Active'),
('POL104', 'C004', 'PKG04', '2025-08-12', '2025-09-12', 'Expired'),
('POL105', 'C005', 'PKG01', '2026-01-01', '2027-01-01', 'Active');

INSERT INTO Claims(Claim_ID, Policy_ID, Claim_Date, Claim_Amount, Status) 
VALUES
('CLM901', 'POL102', '2024-06-15', 12000000,  'Approved'),
('CLM902', 'POL103', '2025-10-20', 50000000,  'Pending'),
('CLM903', 'POL101', '2024-11-05',  5500000,  'Approved'),
('CLM904', 'POL105', '2026-01-15',  2000000,  'Rejected'),
('CLM905', 'POL102', '2025-02-10', 120000000, 'Approved');

INSERT INTO Claim_Processing_Log(Log_ID, Claim_ID, Action_Detail, Recorded_At, Processor) 
VALUES
('L001', 'CLM901', 'Đã nhận hồ sơ hiện trường', '2024-06-15 09:00:00', 'Admin_01'),
('L002', 'CLM901', 'Chấp nhận bồi thường xe tai nạn', '2024-06-20 14:30:00', 'Admin_01'),
('L003', 'CLM902', 'Đang thẩm định hồ sơ bệnh án', '2025-10-21 10:00:00', 'Admin_02'),
('L004', 'CLM904', 'Từ chối do lỗi cố ý của khách hàng', '2026-01-16 16:00:00', 'Admin_03'),
('L005', 'CLM905', 'Đã thanh toán qua chuyển khoản', '2025-02-15 08:30:00', 'Accountant_01');

-- PHẦN 2: TRUY VẤN DỮ LIỆU CƠ BẢN
-- Câu 1: Liệt kê thông tin các hợp đồng có trạng thái 'Active' và có ngày kết thúc trong năm 2026.
SELECT * FROM Policies
WHERE Status = 'Active'
AND End_Date >= '2026-01-01' AND End_Date < '2027-01-01';
-- Câu 2: Lấy thông tin khách hàng (Họ tên, Email) có tên chứa chữ 'Hoàng' và tham gia bảo hiểm từ năm 2025 trở lại đây.
SELECT Full_Name, Email
FROM Customers
WHERE Full_Name LIKE '%Hoàng%'
AND Join_Date >= '2025-01-01';
-- Câu 3: Hiển thị top 3 yêu cầu bồi thường (Claims) có số tiền được yêu cầu cao nhất, bỏ qua yêu cầu cao nhất (lấy từ vị trí số 2 đến số 4).
SELECT *
FROM Claims
ORDER BY Claim_Amount DESC
LIMIT 3 OFFSET 1;

-- PHẦN 3: TRUY VẤN DỮ LIỆU NÂNG CAO
-- Câu 1: Sử dụng JOIN để hiển thị: Tên khách hàng, Tên gói bảo hiểm, Ngày bắt đầu hợp đồng và Số tiền bồi thường (nếu có).
SELECT c.Full_Name, ip.Package_Name, p.Start_Date, cl.Claim_Amount
FROM Policies p
JOIN Customers c ON c.Customer_ID = p.Customer_ID
JOIN Insurance_Packages ip ON ip.Package_ID = p.Package_ID
LEFT JOIN Claims cl ON cl.Policy_ID = p.Policy_ID;
-- Câu 2: Thống kê tổng số tiền bồi thường đã chi trả ('Approved') cho từng khách hàng. Chỉ hiện những người có tổng chi trả > 50.000.000 VNĐ.
SELECT c.Customer_ID, c.Full_Name, SUM(cl.Claim_Amount) AS Total_Approved_Amount
FROM Customers c
JOIN Policies p ON p.Customer_ID = c.Customer_ID
JOIN Claims cl ON cl.Policy_ID = p.Policy_ID
WHERE cl.Status = 'Approved'
GROUP BY c.Customer_ID, c.Full_Name
HAVING SUM(cl.Claim_Amount) > 50000000;
-- Câu 3: Tìm gói bảo hiểm có số lượng khách hàng đăng ký nhiều nhất.
SELECT ip.Package_ID, ip.Package_Name, COUNT(DISTINCT p.Customer_ID) AS Customer_Count
FROM Insurance_Packages ip
JOIN Policies p ON p.Package_ID = ip.Package_ID
GROUP BY ip.Package_ID, ip.Package_Name
ORDER BY Customer_Count DESC
LIMIT 1;

-- PHẦN 4: INDEX VÀ VIEW
-- Câu 1: Tạo Composite Index tên idx_policy_status_date trên bảng Policies cho hai cột: status và start_date.
CREATE INDEX idx_policy_status_date ON Policies(Status, Start_Date);
-- Câu 2: Tạo một View tên vw_customer_summary hiển thị: Tên khách hàng, Số lượng hợp đồng đang sở hữu, và Tổng phí bảo hiểm định kỳ họ phải trả.
CREATE OR REPLACE VIEW vw_customer_summary AS
SELECT c.Customer_ID, c.Full_Name, COUNT(p.Policy_ID) AS Total_Policies, 
COALESCE(SUM(ip.Base_Premium), 0) AS Total_Base_Premium
FROM Customers c
LEFT JOIN Policies p ON p.Customer_ID = c.Customer_ID
LEFT JOIN Insurance_Packages ip ON ip.Package_ID = p.Package_ID
GROUP BY c.Customer_ID, c.Full_Name;
-- PHẦN 5: TRIGGER
-- Câu 1: Viết Trigger trg_after_claim_approved. Khi một yêu cầu bồi thường chuyển trạng thái sang 'Approved'
-- tự động thêm một dòng vào Claim_Processing_Log với nội dung 'Payment processed to customer'

-- Câu 2: Viết Trigger ngăn chặn việc xóa hợp đồng nếu trạng thái của hợp đồng đó đang là 'Active'.
DELIMITER //

CREATE TRIGGER trg_block_delete_active_policy
BEFORE DELETE ON Policies
FOR EACH ROW
BEGIN
    IF OLD.Status = 'Active' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Không được xóa hợp đồng đang Active';
    END IF;
END//

DELIMITER ;

-- PHẦN 6: STORED PROCEDURE 
-- Câu 1:
-- -  Viết Procedure sp_check_claim_limit nhận vào Mã yêu cầu bồi thường. Trả về tham số OUT message:
-- - 'Exceeded' nếu Số tiền yêu cầu > Hạn mức chi trả của gói bảo hiểm tương ứng.
-- - 'Valid' nếu Số tiền yêu cầu <= Hạn mức chi trả.
DELIMITER //
CREATE PROCEDURE sp_check_claim_limit(IN Claim_ID VARCHAR(25),  OUT p_message  VARCHAR(20))
BEGIN
	
END //

DELIMITER ;

-- Câu 2:
-- - Viết Procedure sp_cancel_policy để hủy một hợp đồng:
-- - Bắt đầu giao dịch (Transaction).
-- - Cập nhật trạng thái hợp đồng thành 'Cancelled'.
-- - Ghi log vào Claim_Processing_Log lý do 'Customer requested cancellation'.
-- - COMMIT nếu thành công, ROLLBACK nếu có lỗi xảy ra.


