DROP TABLE Invoice_Details;
DROP TABLE Contract_Manager CASCADE;
DROP TABLE Program_Manager CASCADE;
DROP TABLE Funding_Document;
DROP TABLE Vendor;
DROP TABLE Amendment CASCADE;
DROP TABLE Allocation_Request CASCADE;
DROP TABLE Shipment_Submission;
DROP TABLE Shipping_Carrier;
DROP TABLE Program_Info;
DROP TABLE Employee CASCADE;

--CASCADE;

DELETE FROM Employee;
DELETE FROM Contract_Manager;
DELETE FROM Program_Manager;
DELETE FROM Amendment;
DELETE FROM Program_Info;

DROP SEQUENCE employee_id_seq;
DROP SEQUENCE amend_id_seq;
DROP SEQUENCE invoice_id_seq;
DROP SEQUENCE request_id_seq;
DROP SEQUENCE shipment_submission_id_seq;

CREATE SEQUENCE employee_id_seq INCREMENT 1000 START 10000 OWNED BY Employee.employee_id;
CREATE SEQUENCE amend_id_seq INCREMENT 10 START 20000 OWNED BY Amendment.amend_id;
CREATE SEQUENCE invoice_id_seq INCREMENT 2 START 42001000 OWNED BY Invoice_Details.invoice_id;
CREATE SEQUENCE request_id_seq INCREMENT 10 START 520 OWNED BY Allocation_Request.request_id;
CREATE SEQUENCE shipment_submission_id_seq INCREMENT 1 START 300200 OWNED BY Shipment_Submission.shipment_submission_id;
CREATE SEQUENCE ext_id_seq INCREMENT 1 START 80000 OWNED BY Vendor.external_user_id;
CREATE SEQUENCE alloc_chg_id_seq INCREMENT 1 START 540 OWNED BY Program_Account.alloc_chg_id;

SELECT * FROM Employee;
SELECT * FROM Program_Info;
SELECT * FROM Contract_Manager;
SELECT * FROM Amendment;
SELECT * FROM Vendor;
SELECT * FROM Allocation_Request;
SELECT * FROM Shipment_Submission;
SELECT * FROM Shipping_Carrier;
SELECT * FROM Invoice_Details;


CREATE TABLE Employee(
employee_id DECIMAL(5) NOT NULL,
first_name VARCHAR(32) NOT NULL,
last_name VARCHAR(32) NOT NULL,
is_contract bool NOT NULL,
PRIMARY KEY(employee_id)
);

CREATE OR REPLACE PROCEDURE add_contract_manager(p_employee_id IN DECIMAL(5), p_first_name IN VARCHAR(32),
p_last_name IN VARCHAR(32), p_is_contract IN bool, p_funding_document IN BIGINT)
AS $proc$ BEGIN
 
INSERT INTO Employee(employee_id, first_name, last_name, is_contract)
VALUES(nextval('employee_id_seq'), p_first_name, p_last_name, p_is_contract);

INSERT INTO Contract_Manager(employee_id, funding_document )
VALUES(currval('employee_id_seq'), p_funding_document);

END;
$proc$ LANGUAGE plpgsql

CALL add_contract_manager(nextval('employee_id_seq'), 'Imaan', 'Mac', true, 588902345554);
CALL add_contract_manager(nextval('employee_id_seq'), 'Gaia', 'Foster', true, 689556932331);
CALL add_contract_manager(nextval('employee_id_seq'), 'Alia', 'Ford', true, 435664542132);
CALL add_contract_manager(nextval('employee_id_seq'), 'Grant', 'York', true, 434546634366);
CALL add_contract_manager(nextval('employee_id_seq'), 'Eiliyah', 'Kaye', true, 455664323234);

CREATE TABLE Amendment (
amend_id DECIMAL(5) NOT NULL, -- was INT previously
employee_id DECIMAL(5) NOT NULL,
funding_document BIGINT NOT NULL,
amendment_number DECIMAL(3) NOT NULL,
approval_date DATE NOT NULL,
amendment_amount NUMERIC(13,4) NOT NULL,
PRIMARY KEY(amend_id)
);

SELECT * FROM Amendment;

CREATE TABLE Contract_Manager (
employee_id DECIMAL(5), 
funding_document BIGINT NOT NULL,

CONSTRAINT employee_id_fk
FOREIGN KEY (employee_id)
REFERENCES Employee(employee_id)
);


CREATE TABLE Program_Info (
employee_id DECIMAL(5),
program_id DECIMAL(4) NOT NULL,
program_name VARCHAR(25),
program_category VARCHAR(20),
--recieved_amount NUMERIC(13,4),
--remaining_amount NUMERIC(13,4),
PRIMARY KEY(program_id),
	
CONSTRAINT employee_id_fk
FOREIGN KEY (employee_id)
REFERENCES Employee(employee_id)
);

CREATE TABLE Program_Manager (
employee_id DECIMAL(5),
program_id DECIMAL(4) NOT NULL,
	
CONSTRAINT employee_id_fk
FOREIGN KEY (employee_id)
REFERENCES Employee(employee_id)
);

CREATE TABLE Funding_Document (
amend_id DECIMAL(5),
employee_id DECIMAL(5) NOT NULL,
funding_document BIGINT NOT NULL,
amendment_number DECIMAL(3) NOT NULL,
funded_amount NUMERIC(13,4) DEFAULT 0 NULL,
remaining_amount NUMERIC(13,4) DEFAULT 0 NULL,

CONSTRAINT amend_id_fk
FOREIGN KEY (amend_id)
REFERENCES Amendment(amend_id)
);

CREATE TABLE Program_Account (
alloc_chg_id INTEGER NOT NULL,
request_id INTEGER NOT NULL, --There is a column named "request_id" in table "allocation_change", but it cannot be referenced from this part of the query.
program_id DECIMAL(4) NOT NULL,
program_name VARCHAR(25),
recieved_amount NUMERIC(13,4),
remaining_amount NUMERIC(13,4),
last_update DATE DEFAULT CURRENT_DATE,
PRIMARY KEY(alloc_chg_id),

CONSTRAINT request_id_fk
FOREIGN KEY (request_id) 
REFERENCES Allocation_Request(request_id),

CONSTRAINT program_id_fk
FOREIGN KEY (program_id)
REFERENCES Program_Info(program_id)
);


CREATE TABLE Vendor (
external_user_id DECIMAL(5) NOT NULL,
company_name VARCHAR(25) NOT NULL,
PRIMARY KEY(external_user_id)
);

CREATE TABLE Shipping_Carrier(
service_provider_id DECIMAL(5) NOT NULL,
service_provider VARCHAR(20) NOT NULL,
tracking_number BIGINT NOT NULL,
shipment_status VARCHAR(12) NOT NULL,
date_recieved DATE NOT NULL,
date_delivered DATE, --dropped not null
PRIMARY KEY (tracking_number)
);


CREATE TABLE Shipment_Submission (
shipment_submission_id DECIMAL(6) NOT NULL,
service_provider_id DECIMAL(5),
tracking_number BIGINT NOT NULL,
PRIMARY KEY(shipment_submission_id),

CONSTRAINT carrier_tracking_fk
FOREIGN KEY (tracking_number)
REFERENCES Shipping_Carrier(tracking_number)
);

CREATE TABLE Allocation_Request (
request_id INTEGER NOT NULL,
program_id DECIMAL(4) NOT NULL,	
employee_id DECIMAL(5),
amount_requested NUMERIC(13,4) NOT NULL,
funding_document BIGINT NOT NULL,
request_purpose VARCHAR(255) NOT NULL,
PRIMARY KEY(request_id),
	
CONSTRAINT program_id_fk
FOREIGN KEY (program_id)
REFERENCES Program_Info(program_id),

CONSTRAINT employee_id_fk
FOREIGN KEY (employee_id)
REFERENCES Employee(employee_id)
);


CREATE TABLE Invoice_Details (
external_user_id DECIMAL(5),
company_name VARCHAR(25) NOT NULL,
program_id DECIMAL(4),
program_name VARCHAR(25) NOT NULL,
invoice_id INTEGER NOT NULL,
is_goods_shipment BOOLEAN NOT NULL,
shipment_submission_id DECIMAL(6),
expense_purpose VARCHAR(40),
amount_invoice NUMERIC(13,4) NOT NULL,
PRIMARY KEY(invoice_id),
	
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


--------Adding Program Manager Stored Procedure------ 
 
CREATE OR REPLACE PROCEDURE add_program_manager(p_employee_id IN DECIMAL(5), p_first_name IN VARCHAR(32),
p_last_name IN VARCHAR(32), p_is_contract IN bool, p_program_id IN DECIMAL(4), p_program_name IN VARCHAR(25),
p_program_category VARCHAR(20))
AS $proc$ BEGIN
 
INSERT INTO Employee(employee_id, first_name, last_name, is_contract)
VALUES(nextval('employee_id_seq'), p_first_name, p_last_name, p_is_contract);

INSERT INTO Program_Manager(employee_id, program_id)
VALUES(currval('employee_id_seq'), p_program_id);

INSERT INTO Program_Info(employee_id, program_id, program_name, program_category)
VALUES (currval('employee_id_seq'), p_program_id, p_program_name, p_program_category);

END;
$proc$ LANGUAGE plpgsql

SELECT * FROM Program_info;

CALL add_program_manager(nextval('employee_id_seq'),'Caspian', 'Grey',false, 3221, 'Water Program', 'Health');
CALL add_program_manager(nextval('employee_id_seq'),'Roma', 'Jackson',false, 3231, 'Food Lab Branch', 'Health');
CALL add_program_manager(nextval('employee_id_seq'),'Aliya', 'Li',false, 1212, 'Op Hidden', 'Forensics');
CALL add_program_manager(nextval('employee_id_seq'),'Danielle', 'Baxter', false, 1211, 'CAE-Cyber Ops', 'Anti-Terrorism');
CALL add_program_manager(nextval('employee_id_seq'),'Andy', 'Conley', false, 2323, 'Energy Program', 'Energy');


SELECT * FROM Employee;
SELECT * FROM Contract_Manager;
SELECT * FROM Program_Manager;
SELECT * FROM Amendment;
SELECT * FROM Funding_Document;
SELECT * FROM Program_Info;


CREATE OR REPLACE PROCEDURE add_amendment(
p_amend_id DECIMAL(5),
p_funding_document BIGINT,
p_amendment_number DECIMAL(3),
p_approval_date DATE,
p_amendment_amount NUMERIC(13,4))

LANGUAGE plpgsql
AS $$
DECLARE

v_employee_id DECIMAL(5);

BEGIN

SELECT employee_id
INTO v_employee_id
FROM Contract_Manager
WHERE funding_document = p_funding_document;

INSERT INTO Amendment(amend_id, employee_id, funding_document, amendment_number, approval_date, amendment_amount)
VALUES (nextval('amend_id_seq'), v_employee_id, p_funding_document, p_amendment_number, p_approval_date, p_amendment_amount);
 
INSERT INTO Funding_Document(amend_id, employee_id, funding_document, amendment_number)
VALUES (currval('amend_id_seq'), v_employee_id, p_funding_document, p_amendment_number);

END;
$$;

CALL add_amendment(nextval('amend_id_seq'),588902345554, 000, CAST('12-Jan-21' AS DATE), 500000);
CALL add_amendment(nextval('amend_id_seq'),689556932331, 000, CAST('20-Mar-19' AS DATE), 700000);
CALL add_amendment(nextval('amend_id_seq'),435664542132, 000, CAST('29-Aug-20' AS DATE), 500000);
CALL add_amendment(nextval('amend_id_seq'),434546634366, 000, CAST('3-May-18' AS DATE), 20000);
CALL add_amendment(nextval('amend_id_seq'),455664323234, 000, CAST('12-Sep-21' AS DATE), 750000);

--This is where the amendments are added now. 

CALL add_amendment(nextval('amend_id_seq'),588902345554, 001, CAST('15-Apr-22' AS DATE), 400000);
CALL add_amendment(nextval('amend_id_seq'),435664542132, 001, CAST('23-Sep-20' AS DATE), 1000000);
CALL add_amendment(nextval('amend_id_seq'),435664542132, 002, CAST('10-Dec-20' AS DATE), 300000);
CALL add_amendment(nextval('amend_id_seq'),435664542132, 003, CAST('30-Jan-22' AS DATE), -200000);


	
CREATE OR REPLACE PROCEDURE add_vendor (
p_external_user_id DECIMAL(5),
p_company_name VARCHAR(25))
	
AS $proc$ BEGIN

INSERT INTO Vendor(external_user_id, company_name)
VALUES (nextval('ext_id_seq'), p_company_name);
 
END;
$proc$ LANGUAGE plpgsql

CALL add_vendor(nextval('ext_id_seq'), 'Peak Point Co');
CALL add_vendor(nextval('ext_id_seq'), 'Food Secure');
CALL add_vendor(nextval('ext_id_seq'), 'Chainalysis');
CALL add_vendor(nextval('ext_id_seq'), 'Defensive Works');
CALL add_vendor(nextval('ext_id_seq'), 'Synergy Safety');

SELECT 
Program_Manager.employee_id,
Program_Info.program_name,
Employee.first_name,
Employee.last_name,
Program_Manager.program_id,
TO_CHAR((Invoice_Details.amount_invoice), 'L99G999G999G999D99') AS "Invoice Amount",
Invoice_Details.is_goods_shipment,
Shipment_Submission.shipment_submission_id

FROM Program_Info
INNER JOIN Program_Manager ON Program_Info.program_id= Program_Manager.program_id
INNER JOIN Invoice_Details ON Program_Info.program_id = Invoice_Details.program_id
FULL OUTER JOIN Shipment_Submission ON Invoice_Details.shipment_submission_id = Shipment_Submission.shipment_submission_id
INNER JOIN Employee ON Program_Manager.employee_id = Employee.employee_id


-------------

SELECT
Employee.employee_id,
Employee.is_contract,
Employee.first_name,
Employee.last_name,
Program_Manager.program_id,
Program_Info.program_name,
Contract_Manager.funding_document,
Amendment.amendment_number

FROM Employee
FULL OUTER JOIN Program_Manager ON Employee.employee_id = Program_Manager.employee_id
FULL OUTER JOIN Contract_Manager ON Employee.employee_id = Contract_Manager.employee_id
FULL OUTER JOIN  Program_Info ON Program_Manager.program_id= Program_Info.program_id
FULL OUTER JOIN  Amendment ON Contract_Manager.employee_id = Amendment.employee_id
ORDER BY is_contract ASC;

DROP VIEW Allocation_Req_View;

CREATE VIEW Allocation_Req_View AS
  SELECT Allocation_Request.program_id, 
  Program_Info.program_name,
  first_name,
  last_name,
  request_purpose,
  TO_CHAR((Allocation_request.amount_requested), 'L99G999G999G999D99') AS "Requested Amount",
  Amendment.funding_document,
  TO_CHAR((Amendment.amendment_amount), 'L99G999G999G999D99') AS "Amendment Amount"
 
  FROM Amendment
  INNER JOIN Allocation_request
  ON Amendment.funding_document = Allocation_Request.funding_document
  INNER JOIN Program_Info
  ON Allocation_Request.employee_id = Program_Info.employee_id
  INNER JOIN Employee
  ON Allocation_Request.employee_id = Employee.employee_id
  
  WHERE amount_requested > 100000
  ORDER BY amount_requested DESC;
  

SELECT * FROM Allocation_Req_View;
SELECT * FROM Allocation_Request;

-----------------------------------

INSERT INTO Allocation_Request(request_id, program_id, employee_id, amount_requested, funding_document, request_purpose)
VALUES
(nextval('request_id_seq'), (SELECT program_id from program_manager WHERE program_id ='3221'), (SELECT employee_id from Program_Manager WHERE program_id='3221'), 100000, 588902345554, 'Laboratory Equipment for Water Analysis'),
(nextval('request_id_seq'), (SELECT program_id from program_manager WHERE program_id ='3231'), (SELECT employee_id from Program_Manager WHERE program_id='3231'), 200000, 689556932331, 'ELISA assays, PCR tests and agar plates to perform tests'),
(nextval('request_id_seq'), (SELECT program_id from program_manager WHERE program_id ='1212'), (SELECT employee_id from Program_Manager WHERE program_id='1212'), 700000, 435664542132, 'Chainalysis software to perform research including consultation and training provided.'),
(nextval('request_id_seq'), (SELECT program_id from program_manager WHERE program_id ='1211'), (SELECT employee_id from Program_Manager WHERE program_id='1211'), 240000, 434546634366, 'Software and speicalized training was provided to students to perform tasks. '),
(nextval('request_id_seq'), (SELECT program_id from program_manager WHERE program_id ='2323'), (SELECT employee_id from Program_Manager WHERE program_id='2323'), 90000, 455664323234, 'Technical assistance for cities, counties, special districts,etc. for existing programs')


-----------------------------------

SELECT * FROM Shipping_Carrier;
SELECT * FROM Shipment_Submission;

-------------------------

INSERT INTO Shipping_Carrier(service_provider_id, service_provider, tracking_number, shipment_status, date_recieved, date_delivered)
VALUES
(56677,'UPS', 9034863023,'Delivered',  CAST('20-Dec-21' AS DATE), CAST('3-Feb-22' AS DATE)),
(68944,'FEDEX',35435343555, 'In Process',  CAST('10-Jan-22' AS DATE), null);


INSERT INTO Shipment_Submission(shipment_submission_id, service_provider_id, tracking_number)
VALUES (nextval('shipment_submission_id_seq'),(SELECT service_provider_id from Shipping_Carrier WHERE tracking_number =9034863023), (SELECT tracking_number from Shipping_Carrier WHERE tracking_number =9034863023)),
(nextval('shipment_submission_id_seq'),(SELECT service_provider_id from Shipping_Carrier WHERE tracking_number =35435343555), (SELECT tracking_number from Shipping_Carrier WHERE tracking_number =35435343555))

--drop table Invoice_Details;
SELECT * FROM Invoice_Details;

INSERT INTO Invoice_Details(invoice_id, external_user_id, program_id, is_goods_shipment, shipment_submission_id, expense_purpose, amount_invoice, company_name, program_name)
VALUES (nextval('invoice_id_seq'),(SELECT external_user_id from Vendor WHERE company_name = 'Peak Point Co'),3221 ,TRUE, (SELECT shipment_submission_id from Shipment_Submission WHERE tracking_number =9034863023),
'instrumentation equipment',50000, 'Peak Point Co', 'Water Program'), 

(nextval('invoice_id_seq'),(SELECT external_user_id from Vendor WHERE company_name = 'Food Secure'), 3231, TRUE, (SELECT shipment_submission_id from Shipment_Submission WHERE tracking_number =35435343555),
'Lab test equipment',20000, 'Food Secure', 'Food Lab Branch'),

(nextval('invoice_id_seq'),(SELECT external_user_id from Vendor WHERE company_name = 'Chainalysis'), 1212, FALSE, NULL,
'Forensics software and consult',120000, 'Chainalysis', 'Op Hidden Treasure'),(nextval('invoice_id_seq'),(SELECT external_user_id from Vendor WHERE company_name = 'Defensive Works'), 1211, FALSE, NULL,
'Software and training',100000, 'Defensive Works', 'CAE-Cyber Ops Program'),

(nextval('invoice_id_seq'),(SELECT external_user_id from Vendor WHERE company_name = 'Synergy Safety'), 2323, FALSE, NULL,
'Develop simulation models',60000, 'Synergy Safety', 'Energy Program');

ROLLBACK;

--CALL add_invoice(nextval('amend_id_seq'),588902345554, 000, CAST('12-Jan-21' AS DATE), 500000);


-------indexes

CREATE INDEX contract_manage_index
ON Contract_Manager (employee_id);

CREATE INDEX program_manager_index
ON Program_Manager (employee_id);

CREATE INDEX program_info_index
ON Program_Info (employee_id);

CREATE INDEX funding_document_index
ON Funding_Document (funding_document,amendment_number);

CREATE INDEX shipment_submission_index
ON Shipment_Submission (service_provider_id,tracking_number);

CREATE INDEX allocation_request_index
ON Allocation_Request (program_id);

CREATE INDEX invoice_details_index
ON Invoice_Details(external_user_id,program_id,shipment_submission_id);

--DELETE FROM Funding_Document;
SELECT * FROM Funding_Document;

--WORKS - DOES THIS TRIGGER WORK 

CREATE FUNCTION total_funded_amount() RETURNS TRIGGER
AS $$
  	BEGIN
	--SET
  	NEW.funded_amount := OLD.funded_amount + NEW.amendment_amount; -- funded_amount = previous funds balance + new funds
  	INSERT INTO Funding_Document(alloc_chg_id, amend_id,funding_document, old_funded_amt, new_funded_amt)
	VALUES(nextval('alloc_chg_id_seq'), request_id, OLD.funded_amount, NEW.funded_amount, funded_amount, last_update);
    RETURN NEW;         
  	END
	$$ LANGUAGE plpgsql;

CREATE TRIGGER total_funded_amount_trg
AFTER INSERT OR UPDATE ON Amendment
FOR EACH ROW EXECUTE PROCEDURE total_funded_amount();

-------------------

RETURNS TRIGGER LANGUAGE plpgsql
AS $trigfunc$
BEGIN
INSERT INTO Allocation_Change(alloc_chg_id, request_id, old_funded_amt, new_funded_amt, funding_document, chg_date)
VALUES(nextval('alloc_chg_id_seq'), request_id, OLD.funded_amount, NEW.funded_amount, last_update);
RETURN NEW;
END;
$trigfunc$;


------------

SELECT * FROM Program_Account;
DROP TABLE Program_Account;
ROLLBACK;
-- Should I do a join here instead of using the same values?
CREATE TABLE Program_Account (
alloc_chg_id INTEGER NOT NULL,
request_id INTEGER NOT NULL, --There is a column named "request_id" in table "allocation_change", but it cannot be referenced from this part of the query.
program_id DECIMAL(4) NOT NULL,
program_name VARCHAR(25),
recieved_amount NUMERIC(13,4),
remaining_amount NUMERIC(13,4),
last_update DATE DEFAULT CURRENT_DATE,
PRIMARY KEY(alloc_chg_id),

CONSTRAINT request_id_fk
FOREIGN KEY (request_id) 
REFERENCES Allocation_Request(request_id),

CONSTRAINT program_id_fk
FOREIGN KEY (program_id)
REFERENCES Program_Info(program_id)
);


--IF AND INSERT ---UPDATE SET -- This tracks allocation changes table 
CREATE OR REPLACE FUNCTION allocation_chg()
RETURNS TRIGGER LANGUAGE plpgsql
AS $trigfunc$
BEGIN
INSERT INTO Allocation_Change(alloc_chg_id, request_id, program_id, program_name, old_funded_amount, new_funded_amount, last_update)
VALUES(nextval('alloc_chg_id_seq'), request_id, program_id, program_name, OLD.funded_amount, NEW.funded_amount, last_update);
--QUESTION HERE, SHOULD I USE A SUBQUERY OR A JOIN IN TRIGGER INSERT INTO TABLE.

RETURN NEW;
END;
$trigfunc$;

CREATE TRIGGER alloc_chg_trig
AFTER INSERT OR UPDATE ON Allocation_Request
FOR EACH ROW
--WHEN 
EXECUTE PROCEDURE allocation_chg();



