DROP TABLE Reject;
DROP TABLE Accept;
DROP TABLE Invoice_Details;
DROP TABLE Contract_Manager;
DROP TABLE Program_Manager;
DROP TABLE Funding_Document;
DROP TABLE Vendor;
DROP TABLE Amendment;
DROP TABLE Allocation_Request;
DROP TABLE Shipment_Submission;
DROP TABLE Shipping_Carrier; -- CASCADE;
DROP TABLE Program_Info;
DROP TABLE Employee;

DROP SEQUENCE invoice_id_seq;
DROP SEQUENCE request_id_seq;
DROP SEQUENCE shipment_submission_id_seq;


SELECT * 
FROM Employee;

SELECT * 
FROM Program_Info;

SELECT * 
FROM Contract_Manager;

SELECT * 
FROM Funding_Document;

SELECT * 
FROM Vendor;

SELECT * 
FROM  Allocation_Request;

SELECT * 
FROM Shipment_Submission;

SELECT * 
FROM Shipping_Carrier;

SELECT * 
FROM Invoice_Details;

SELECT * 
FROM Reject;

SELECT * 
FROM Accept;


--ROLLBACK;

CREATE TABLE Employee (
employee_id DECIMAL(5) NOT NULL PRIMARY KEY,
job_type VARCHAR(20) NOT NULL
);

CREATE TABLE Amendment (
employee_id DECIMAL(5) NOT NULL,
funding_document DECIMAL(12) NOT NULL,
amendment_number DECIMAL(3) NOT NULL,
approval_date DATE NOT NULL,
amendment_amount NUMERIC(13,4) NOT NULL,
PRIMARY KEY (funding_document, amendment_number)
);


CREATE TABLE Contract_Manager (
employee_id DECIMAL(5) NOT NULL,
funding_document DECIMAL(12),
amendment_number DECIMAL(3),
--request_id DECIMAL(5),
approve_request BOOLEAN,

CONSTRAINT employee_id_fk
FOREIGN KEY (employee_id)
REFERENCES Employee(employee_id),

CONSTRAINT fund_doc_fk
FOREIGN KEY (funding_document, amendment_number)
REFERENCES Amendment(funding_document, amendment_number)
);

CREATE TABLE Program_Info (
employee_id DECIMAL(5),
program_id DECIMAL(4) NOT NULL PRIMARY KEY,
program_name VARCHAR(25),
program_category VARCHAR(20),
recieved_amount DECIMAL(13,4),
remaining_amount NUMERIC(13,4),
	
CONSTRAINT employee_id_fk
FOREIGN KEY (employee_id)
REFERENCES Employee(employee_id)
);

CREATE TABLE Program_Manager (
employee_id DECIMAL(5) NOT NULL,
program_id DECIMAL(4),
	
CONSTRAINT employee_id_fk
FOREIGN KEY (employee_id)
REFERENCES Employee(employee_id)
);

CREATE TABLE Funding_Document (
employee_id DECIMAL(5) NOT NULL,
funding_document DECIMAL(12) NOT NULL,
amendment_number DECIMAL(3) NOT NULL,
funded_amount NUMERIC(13,4) NOT NULL,
remaining_amount NUMERIC(13,4) NOT NULL,

CONSTRAINT fund_doc_fk
FOREIGN KEY (funding_document, amendment_number)
REFERENCES Amendment(funding_document, amendment_number)
);

CREATE TABLE Vendor (
external_user_id DECIMAL(5) NOT NULL PRIMARY KEY,
company_name DECIMAL(4) NOT NULL
);

CREATE TABLE Shipping_Carrier(
service_provider_id DECIMAL(5) NOT NULL,
service_provider VARCHAR(20) NOT NULL,
tracking_number DECIMAL(30) NOT NULL,
shipment_status VARCHAR(12) NOT NULL,
date_recieved DATE NOT NULL,
date_delivered DATE NOT NULL, 
PRIMARY KEY (service_provider_id, tracking_number)
);

CREATE TABLE Shipment_Submission (
shipment_submission_id DECIMAL(6) NOT NULL PRIMARY KEY,
service_provider_id DECIMAL(5),
tracking_number DECIMAL(30),

CONSTRAINT carrier_tracking_fk
FOREIGN KEY (service_provider_id, tracking_number)
REFERENCES Shipping_Carrier(service_provider_id, tracking_number)
);


CREATE TABLE Allocation_Request (
request_id DECIMAL(5) NOT NULL PRIMARY KEY,
program_id DECIMAL(4),	
employee_id DECIMAL(5),
amount_requested NUMERIC(13,4),
funding_document DECIMAL(12),
request_purpose VARCHAR(255),

CONSTRAINT program_id_fk
FOREIGN KEY (program_id)
REFERENCES Program_Info(program_id),

CONSTRAINT employee_id_fk
FOREIGN KEY (employee_id)
REFERENCES Employee(employee_id)
);

CREATE TABLE Reject (
request_id DECIMAL(5),
program_id DECIMAL(4),
is_reject BOOL NOT NULL,

CONSTRAINT request_id_fk
FOREIGN KEY (request_id)
REFERENCES  Allocation_Request(request_id),
	
CONSTRAINT program_id_fk
FOREIGN KEY (program_id)
REFERENCES Program_Info(program_id)
);

CREATE TABLE Accept (
request_id DECIMAL(5),
program_id DECIMAL(4),
is_accept BOOL NOT NULL,

CONSTRAINT request_id_fk
FOREIGN KEY (request_id)
REFERENCES  Allocation_Request(request_id),
	
CONSTRAINT program_id_fk
FOREIGN KEY (program_id)
REFERENCES Program_Info(program_id)
);

CREATE TABLE Invoice_Details (
external_user_id DECIMAL(5),
program_id DECIMAL(4),
invoice_id DECIMAL(8) NOT NULL PRIMARY KEY,
is_goods_shipment BOOLEAN NOT NULL,
shipment_submission_id DECIMAL(6),
expense_purpose VARCHAR(40),
amount_invoice NUMERIC(13,4) NOT NULL,

CONSTRAINT external_user_id_fk
FOREIGN KEY (external_user_id)
REFERENCES Vendor(external_user_id),
	
CONSTRAINT program_id_fk
FOREIGN KEY (program_id)
REFERENCES Program_Info(program_id),

CONSTRAINT shipment_submission_id_fk
FOREIGN KEY (shipment_submission_id)
REFERENCES Shipment_Submission(shipment_submission_id)
);

CREATE SEQUENCE invoice_id_seq START WITH 1;
CREATE SEQUENCE request_id_seq START WITH 1;
CREATE SEQUENCE shipment_submission_id_seq START WITH 1;


--------Adding Contract Manager------ 
CREATE OR REPLACE PROCEDURE Add_Contract_Manager(employee_id IN DECIMAL(5), job_type IN VARCHAR(20))

AS
$proc$
BEGIN

INSERT INTO Employee(employee_id, job_type)
VALUES(employee_id, job_type);

INSERT INTO Contract_Manager(employee_id)
VALUES(employee_id);
					 
END;
$proc$ LANGUAGE plpgsql

ROLLBACK; 

START TRANSACTION;
DO
$$BEGIN
CALL Add_Contract_Manager
(32233,'Contracts');
END$$;
COMMIT TRANSACTION;


--------Adding Program Manager------ 

CREATE OR REPLACE PROCEDURE Add_Program_Manager(employee_id IN DECIMAL(5), job_type IN VARCHAR(20), program_id IN DECIMAL(4), program_name IN VARCHAR(25),
program_category VARCHAR(20), recieved_amount IN NUMERIC(13,4))
AS $proc$ BEGIN

INSERT INTO Employee(employee_id IN DECIMAL(5), job_type IN VARCHAR(20))
VALUES(employee_id, job_type);


INSERT INTO Program_Manager(employee_id, program_id)
VALUES(employee_id, program_id);


INSERT INTO Program_Info(employee_id IN DECIMAL(5), job_type IN VARCHAR(20), program_id IN DECIMAL(4), program_name IN VARCHAR(25),
program_category VARCHAR(20), recieved_amount IN NUMERIC(13,4))
VALUES Funding_Document(employee_id, job_type, program_id, program_name, program_category,recieved_amount);

END;
$proc$ LANGUAGE plpgsql
					 
START TRANSACTION;
DO
$$BEGIN
CALL Add_Program_Manager
(32233, 'Program', 588902345554, 000, CAST('12-Jan-21' AS DATE), 500000),
(32400, 'Program', 689556932331, 000, CAST('20-Mar-19' AS DATE), 700000),
(32988, 'Program', 435664542132, 000, CAST('29-Aug-20' AS DATE),  20000),
(32555, 'Program', 434546634366, 000, CAST('3-May-18' AS DATE), 750000),
(32441, 'Program', 455664323234, 000, CAST('12-Sep-21' AS DATE), 4000000));

END$$;
COMMIT TRANSACTION;

			
--------Add_Vendor------ 		
CREATE OR REPLACE PROCEDURE Add_Vendor(external_user_id IN DECIMAL(4), company_name IN VARCHAR(25))
AS
$proc$
BEGIN
INSERT INTO Vendor(external_user_id, company_name)

VALUES(89903,'Peak Point Co'), (80001,'Synergy Safety', (81223,'Chainalysis'),
(83342,'Defensive Works'), (80225,'Synergy Safety');

END;
$proc$ LANGUAGE plpgsql

Call Add_Vendor;

--------Add_Amendment------
CREATE OR REPLACE PROCEDURE Add_Amendment(employee_id, funding_document IN DECIMAL, amendment_number IN DECIMAL,
approval_date DATE, amendment_amount IN DECIMAL)
AS
$proc$
BEGIN
INSERT INTO Amendent(employee_id IN DECIMAL(5), funding_document IN DECIMAL, amendment_number IN DECIMAL,
approval_date DATE, amendment_amount IN NUMERIC(13,4))
VALUES(32233, 588902345554,000, 300000, CAST('12-Jan-21' AS DATE),500000);

INSERT INTO Funding_Document(funding_document IN DECIMAL(12), amendment_number IN DECIMAL(3),
approval_date DATE, amendment_amount IN NUMERIC(13,4))

VALUES Funding_Document(funding_document, amendment_number);

END;
$proc$ LANGUAGE plpgsql

Call Add_Amendment;

--------Add_Amendment------ 

create or replace procedure Add_fund_amt_up(
   amendment_amount int,
  remaining_amount int
)

language plpgsql    
as $$
begin
    -- subtracting the amount from the funding document account 
    update Funding_Documents
    set remaining_amount = remaining_amount - amendment_amount
    where id = sender;

    -- adding the amount to the receiver's account
    update accounts 
    set balance = balance + amount 
    where id = receiver;
	
	commit;
	end;$$;

---ANSWER------
								
CREATE OR REPLACE PROCEDURE Add_Contract_Manager(employee_id IN DECIMAL(5), job_type IN VARCHAR(20), funding_document IN DECIMAL(12),
amendment_number IN DECIMAL(3),approval_date DATE, amendment_amount IN NUMERIC(13,4))


LANGUAGE plpgsql
AS $$
DECLARE

								
v_funding_document DECIMAL(12); 

BEGIN

SELECT person_id
INTO v_person_id
FROM Person
WHERE username = p_username;

INSERT INTO Likes(likes_id, person_id, post_id, liked_on)
VALUES(nextval('likes_seq'), v_person_id, p_post_id, p_liked_on);
END;
$$;

CALL add_like('ad_cat90', 34, CAST('08-DEC-2014' AS DATE));
