SELECT * FROM billing
SELECT * FROM departments
SELECT * FROM diagnoses
SELECT * FROM doctors
SELECT * FROM medications
SELECT * FROM patients
SELECT * FROM visits

--Find the total number of patients.
SELECT COUNT(patient_id) AS total_patients
FROM patients

--Get the average visit cost (from billing), then list all visits with above-average total cost.
SELECT v.visit_id,SUM(total_cost) AS sum_of_total
FROM visits v
JOIN billing b ON v.visit_id=b.visit_id
GROUP BY v.visit_id 
HAVING SUM(total_cost) > 
(
SELECT AVG(total_cost) AS average_cost
FROM(
SELECT visit_id,SUM(total_cost) AS sum_total
FROM billing
GROUP BY visit_id
)
);


SELECT v.visit_id,
       SUM(b.total_cost) AS sum_of_total
FROM visits v
JOIN billing b ON v.visit_id = b.visit_id
GROUP BY v.visit_id
HAVING SUM(b.total_cost) > (
       SELECT AVG(sum_total)
       FROM (
            SELECT visit_id, SUM(total_cost) AS sum_total
            FROM billing
            GROUP BY visit_id
       ) AS x
);



SELECT v.visit_id,
       SUM(b.total_cost) AS sum_of_total
FROM visits v
JOIN billing b ON v.visit_id = b.visit_id
GROUP BY v.visit_id
HAVING SUM(b.total_cost) > (
       SELECT AVG(sum_total)
       FROM (
            SELECT visit_id, SUM(total_cost) AS sum_total
            FROM billing
            GROUP BY visit_id
       ) AS x
);

--Show all doctors whose doctor_id is greater than the average doctor_id.
SELECT doctor_id,first_name,last_name
FROM doctors
WHERE doctor_id >(
SELECT AVG(doctor_id) AS average_id
FROM doctors
);

--List patients who are older than the average age of all patients.
SELECT first_name,last_name,EXTRACT(YEAR FROM AGE(date_of_birth)) AS age
FROM patients
WHERE EXTRACT(YEAR FROM AGE(date_of_birth)) >(
SELECT AVG(EXTRACT(YEAR FROM AGE(date_of_birth)))
FROM patients
);

--Show all departments whose department_id is in the list of department_ids that have doctors.
SELECT de.department_id,de.department_name
FROM departments de
WHERE de.department_id IN (
SELECT d.department_id
FROM doctors d
);


--Find all patients who have more visits than the average visits per patient.
SELECT COUNT(p.patient_id),p.first_name,p.last_name
FROM patients p
JOIN visits v ON v.patient_id=p.patient_id
GROUP BY p.first_name,p.last_name
HAVING COUNT(p.patient_id) >(
SELECT AVG(p.patient_id)
FROM (
SELECT COUNT(p.patient_id) AS total_count
FROM patients p
)AS X
);

--List the doctors who have made more diagnoses than the doctor with doctor_id = 10.
SELECT 
    doc.doctor_id,
    doc.first_name,
    doc.last_name,
    COUNT(d.diagnosis_id) AS diag_count
FROM diagnoses d
JOIN visits v ON v.visit_id = d.visit_id
JOIN doctors doc ON doc.doctor_id = v.doctor_id
GROUP BY doc.doctor_id, doc.first_name, doc.last_name
HAVING COUNT(d.diagnosis_id) >
(
    SELECT COUNT(d2.diagnosis_id)
    FROM diagnoses d2
    JOIN visits v2 ON v2.visit_id = d2.visit_id
    WHERE v2.doctor_id = 10
);

--Show visits where the total billing is higher than the maximum single-visit billing.
SELECT v.visit_id,SUM(total_cost) AS costttt
FROM billing b
JOIN visits v ON v.visit_id=b.visit_id
GROUP BY v.visit_id
HAVING SUM(total_cost) > (
SELECT MAX(total_cost) AS total_max
FROM billing b
);


--Show all medications where the drug_name appears more than once in the medications table.
SELECT *
FROM medications m
WHERE m.drug_name IN (
    SELECT drug_name
    FROM medications
    GROUP BY drug_name
    HAVING COUNT(*) > 1
); 

--Find all doctors who belong to the same department as doctor_id = 5.
SELECT first_name, last_name
FROM doctors
WHERE department_id = (
    SELECT department_id
    FROM doctors
    WHERE doctor_id = 5
);