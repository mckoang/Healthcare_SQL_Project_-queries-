select * from doctors
select * from patients
select * from departments
select * from billing
select * from visits
select * from diagnoses
select * from medications
--How many doctors, patients, and departments exist in the database?
SELECT
(SELECT COUNT(*) FROM doctors) AS total_doctors,
(SELECT COUNT(*) FROM patients) AS total_patients,
(SELECT COUNT(*) FROM departments) AS total_departments;

--List all departments and the number of doctors in each.
SELECT department_name, COUNT(doctor_id) AS total_doctors
FROM departments de
LEFT JOIN doctors d ON d.department_id=de.department_id
GROUP BY department_name;

--Show the total number of patient visits per doctor.
SELECT first_name, last_name, COUNT(patient_id) AS patient_count
FROM visits v
LEFT JOIN doctors d ON d.doctor_id=v.doctor_id
GROUP BY first_name, last_name
ORDER BY patient_count DESC;

--Display the list of patients along with their latest visit date.
SELECT first_name,last_name, MAX(visit_date) AS latest_date
FROM patients p
LEFT JOIN visits v ON p.patient_id=v.patient_id
GROUP BY first_name,last_name
ORDER BY latest_date DESC;

--Retrieve the top 10 most recent visits with patient and doctor names.
SELECT p.first_name AS patient_first_name ,p.last_name AS patient_last_name, 
d.first_name AS doctor_first_name, d.last_name AS doctor_last_name, MAX(visit_date) AS latest_date
FROM patients p
JOIN visits v ON p.patient_id=v.patient_id
JOIN doctors d ON d.doctor_id=v.doctor_id
GROUP BY p.first_name, p.last_name,d.first_name, d.last_name
ORDER BY latest_date DESC
LIMIT 10;

--Find all visits that happened in the last 30 days.
SELECT * FROM visits
WHERE visit_date>=CURRENT_DATE - INTERVAL '30days';

--List patients who have never had any visits.
SELECT first_name, last_name
FROM patients p
LEFT JOIN visits v ON v.patient_id=p.patient_id
WHERE visit_date IS NULL;

--Show doctors who do not belong to any department.
SELECT first_name,last_name
FROM doctors d
LEFT JOIN departments de ON de.department_id=d.department_id
WHERE department_name IS NULL;

--Retrieve all diagnoses made for a specific patient.
SELECT first_name,last_name,diagnosis_name FROM diagnoses di
JOIN visits v ON v.visit_id=di.visit_id
JOIN patients p ON p.patient_id=v.patient_id
WHERE p.patient_id=723
GROUP BY diagnosis_name,first_name,last_name;

--Display all medications prescribed during a specific visit.
SELECT drug_name, visit_id FROM medications m
WHERE visit_id =1;

--Find the average number of visits per patient.
SELECT AVG(total_visit_count) AS Avg_count
FROM (
SELECT first_name,last_name, COUNT(visit_id) AS total_visit_count
FROM visits v
JOIN patients p ON v.patient_id=p.patient_id
GROUP BY first_name,last_name
)AS patient_visits;

--Rank doctors based on the number of patients they have seen.
SELECT d.first_name,d.last_name, COUNT(p.patient_id) AS patient_count,
RANK() OVER(ORDER BY COUNT(p.patient_id) ASC) AS doctor_rank
FROM doctors d
JOIN visits v ON d.doctor_id=v.doctor_id
JOIN patients p ON p.patient_id=v.patient_id
GROUP BY d.first_name,d.last_name
ORDER BY doctor_rank DESC;

--Calculate the total and average billing amount per department.
SELECT de.department_name,
       SUM(total_cost) AS total_bill,
       AVG(total_cost) AS average_bill
FROM billing b
JOIN visits v ON v.visit_id=b.visit_id
JOIN doctors d ON d.doctor_id=v.doctor_id
JOIN departments de ON de.department_id=d.department_id
GROUP BY de.department_name
ORDER BY total_bill DESC, average_bill DESC;

--Determine which doctor has the highest average billing per visit.
SELECT d.first_name,d.last_name, AVG(b.total_cost) AS average_bill
FROM billing b
JOIN visits v ON v.visit_id=b.visit_id
JOIN doctors d ON d.doctor_id=v.doctor_id
GROUP BY d.first_name,d.last_name
ORDER BY average_bill DESC
LIMIT 3;

--USING RANK
SELECT d.first_name,d.last_name, AVG(b.total_cost) AS average_bill,
RANK() OVER (ORDER BY AVG(b.total_cost) DESC) AS bill_rank
FROM billing b
JOIN visits v ON v.visit_id=b.visit_id
JOIN doctors d ON d.doctor_id=v.doctor_id
GROUP BY d.first_name,d.last_name
ORDER BY average_bill DESC
LIMIT 3;

--Identify patients with above-average visit frequency.
SELECT 
    p.first_name,
    p.last_name,
    COUNT(v.visit_id) AS total_visits
FROM patients p
JOIN visits v ON p.patient_id = v.patient_id
GROUP BY p.first_name, p.last_name
HAVING COUNT(v.visit_id) > (
    SELECT AVG(total_visits)
    FROM (
        SELECT COUNT(visit_id) AS total_visits
        FROM visits
        GROUP BY patient_id
    ) AS sub
);

--Show the distribution of visit counts across all patients (min, max, avg).
SELECT 
    MIN(patient_visit_count) AS min_visits,
    MAX(patient_visit_count) AS max_visits,
    AVG(patient_visit_count) AS avg_visits
FROM (
    SELECT 
        p.patient_id,
        COUNT(v.visit_id) AS patient_visit_count
    FROM patients p
    LEFT JOIN visits v ON p.patient_id = v.patient_id
    GROUP BY p.patient_id
) AS visit_summary;







