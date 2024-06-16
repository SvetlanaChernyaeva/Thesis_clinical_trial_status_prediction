SELECT current_database()


set search_path to ctgov 

DROP TABLE IF EXISTS study_searches, study_references, retractions, result_contacts, 
provided_documents, result_agreements, documents, 
ipd_information_types, links, participant_flows, pending_results, provided_documents, reported_event_totals, 
study_searches

DROP TABLE IF EXISTS id_information, search_results, keywords, overall_officials CASCADE


/*Delete the column result_group_id from tables that are needed to be left. (Constraints don't exist). */
alter table baseline_counts drop column if exists result_group_id

alter table baseline_measurements drop column if exists result_group_id

alter table milestones drop column if exists result_group_id

/*Delete the column result_group_id from tables that are needed to be deleted also*/
alter table if exists outcome_counts drop column if exists result_group_id

alter table if exists outcome_analysis_groups drop column if exists result_group_id

alter table if exists outcome_measurements drop column if exists result_group_id

alter table if exists reported_events drop column if exists result_group_id

alter table if exists drop_withdrawals drop column if exists result_group_id

alter table if exists facility_investigators drop column if exists facility_id

alter table if exists outcome_measurements drop column if exists outcome_id

alter table if exists outcome_analysis_groups drop column if exists outcome_analysis_id

alter table if exists outcome_counts drop column if exists outcome_id

alter table if exists intervention_other_names drop column if exists intervention_id

alter table if exists design_group_interventions drop column if exists design_group_id

alter table if exists design_group_interventions drop column if exists intervention_id

alter table if exists facility_contacts drop column if exists facility_id

alter table if exists outcome_analyses drop column if exists outcome_id


/* Now we can delete the rest of the tables that we don't need.*/
DROP TABLE IF exists facility_investigators, drop_withdrawals, reported_events, result_groups, 
outcome_measurements, outcome_analysis_groups, outcome_counts, intervention_other_names, design_group_interventions, 
facility_contacts



/* 
АНАЛИТИКА
<название таблицы>:
 <колонки, которые хочу оставить>


studies: 
 nct_id
 start_month_year или start_date (одно и то же но в разном формате),
 completion_date
 study_type - отфильтровать Interventional
 brief_title, official_title
 overall_status - отфильтровать Terminated, Completed, Withdrawn
 phase
 enrollment, enrollment_type - сколько набрали пациентов (этот параметр мб можно использовать для оценки степени неудачи исследования)
 number_of_arms
 number_of_groups
 why_stopped
 has_expanded_access (это регулируемый процесс, который позволяет пациентам получать экспериментальные лекарства, процедуры или терапии за пределами клинических испытаний. Это может быть разрешено, когда нет удовлетворительных альтернативных лечений и когда пациент не соответствует критериям для участия в клиническом испытании. Расширенный доступ обычно используется для пациентов с серьезными или смертельными заболеваниями.)
 has_dmc ("Data Monitoring Committee" (DMC), также известному как Data and Safety Monitoring Board (DSMB). Это независимая группа экспертов, которая мониторит безопасность и целостность данных во время клинического исследования. Если в документации клинического исследования указано "has_dmc", это означает, что в исследовании есть комитет по мониторингу данных, который отвечает за периодический анализ промежуточных данных для оценки безопасности, эффективности и проведения исследования и, при необходимости, может рекомендовать его изменение, приостановление или прекращение.)
 expanded_access_type_individual, expanded_access_type_intermediate, expanded_access_type_treatment - можно оставить, если там не слишком большое число NA
 FDA регулирование я бы не включала, потому что все препараты важные подлежат регулированию (а БАДЫ я бы вообще убрала из исследования) 
 source_class - источник финансирования, я бы включила (там не сам ичточник, а группа, нужно проанализировать)
 
 calculated_values:
 id
 nct_id
 number_of_facilities
 registered_in_calendar_year
 actual_duration
 has_us_facility
 has_single_facility
 minimum_age_num, maximum_age_num - можно сделать три группы возрастов, до 18 лет, взрослые и пожилые
 minimum_age_unit, maximum_age_unit
 number_of_primary_outcomes_to_measure
 number_of_secondary_outcomes_to_measure
 number_of_other_outcomes_to_measure
 
interventions:
id
nct_id
intervention_type

design_groups:
id
nct_id
group_type (Experimental, Placebo Comparator, Active Comparator - одобренное или стандартное лечение) 

countries: - полностью оставляю, для каждого трайла указаны страны, в которых рекрутироались (мб избыточно, так как отдельно есть кол-во стран и США да/нет)

designs: 
id
nct_id
allocation
intervention_model
masking
subject_masked
caregiver_masked
investigator_masked
outcomes_assessor_masked

detailed_descriptions: предполагаю, что можно просто забрать длину описания как фичу

eligibilities:
id
nct_id
sampling_method - вероятностная выборка часто используется для обеспечения того, чтобы выборка участников адекватно отражала популяцию, для которой предназначено вмешательство или терапия
gender ??? не уверена, что это нужно включать как фичу, но пока оставлю
healthy_volunteers - имеет смысл оставить только для первой фазы
criteria - нужно будет подсчитать число критериев (по новым строкам)
gender_based - можно использовать вместо gender, хотя в этой фиче мало данных, лучше сгенерировать ее заново на основе gender фичи

outcome_analyses:
id
nct_id
non_inferiority_type

responsible_parties:
id
nct_id
responsible_party_type (Sponsor, Principal Investigator)

sponsors: 
id
nct_id
agency_class
lead_or_collaborator

facilities: исследование и все его локации, то есть на одно исследование будет столько строк, сколько и локаций
id
nct_id
city
state
country

 
 Таблицы, которые я думаю все-таки удалить по итогу анализа: 
design_outcomes
оutcomes - мне не нужны конкретные описания конечных точек, будет достаточно количества конечных точек, а оно уже определено в др таблице
baseline_counts - это baseline исходный размер выборки в каждой группе (то есть эти данные мы получаем не на этапе планирования исследования, а когда уже набраны пациенты)
baseline_measurements - то же самое, это когда уже группы набраны
milestones - это что просходило с количеством пациентов на разных этапах
*/

DROP view IF exists all_design_outcomes, all_primary_outcome_measures, all_secondary_outcome_measures

DROP view IF exists all_sponsors, all_states, all_interventions, all_intervention_types, all_group_types,
all_browse_interventions, all_cities, all_conditions, all_facilities, all_browse_conditions

DROP TABLE IF exists design_outcomes, outcomes, baseline_counts, baseline_measurements, milestones


/* Drop columns I don't need*/
alter table if exists studies 
drop column if exists nlm_download_date_description,
drop column if exists study_first_submitted_date, 
drop column if exists results_first_submitted_date, 
drop column if exists disposition_first_submitted_date, 
drop column if exists last_update_submitted_date,
drop column if exists study_first_submitted_qc_date, 
drop column if exists study_first_posted_date, 
drop column if exists study_first_posted_date_type, 
drop column if exists results_first_submitted_qc_date,
drop column if exists results_first_posted_date, 
drop column if exists results_first_posted_date_type, 
drop column if exists disposition_first_submitted_qc_date,
drop column if exists disposition_first_posted_date, 
drop column if exists disposition_first_posted_date_type, 
drop column if exists last_update_submitted_qc_date,
drop column if exists last_update_posted_date, 
drop column if exists last_update_posted_date_type, 
drop column if exists verification_month_year, 
drop column if exists verification_date,
drop column if exists primary_completion_month_year, 
drop column if exists target_duration, 
drop column if exists primary_completion_date, 
drop column if exists primary_completion_date_type,
drop column if exists acronym, 
drop column if exists baseline_population, 
drop column if exists last_known_status, 
drop column if exists "source", 
drop column if exists updated_at, 
drop column if exists created_at,
drop column if exists plan_to_share_ipd_description, 
drop column if exists ipd_url, 
drop column if exists is_fda_regulated_device, 
drop column if exists is_unapproved_device, 
drop column if exists is_ppsd, 
drop column if exists is_us_export, 
drop column if exists biospec_retention, 
drop column if exists biospec_description, 
drop column if exists ipd_time_frame,  
drop column if exists ipd_access_criteria,
drop column if exists delayed_posting, 
drop column if exists baseline_type_units_analyzed, 
drop column if exists fdaaa801_violation, 
drop column if exists expanded_access_status_for_nctid, 
drop column if exists start_date_type,
drop column if exists completion_date_type,
drop column if exists start_month_year,
drop column if exists completion_month_year


alter table if exists calculated_values
drop column if exists number_of_nsae_subjects,
drop column if exists number_of_sae_subjects,
drop column if exists nlm_download_date,
drop column if exists were_results_reported,
drop column if exists months_to_report_results,
drop column if exists id


alter table if exists interventions
drop column if exists "name",
drop column if exists description,
drop column if exists id


alter table if exists design_groups
drop column if exists title,
drop column if exists description,
drop column if exists id


alter table if exists designs
drop column if exists observational_model,
drop column if exists time_perspective,
drop column if exists masking_description,
drop column if exists intervention_model_description,
drop column if exists id


alter table if exists eligibilities
drop column if exists population,
drop column if exists minimum_age,
drop column if exists maximum_age,
drop column if exists gender_description,
drop column if exists adult,
drop column if exists child,
drop column if exists older_adult,
drop column if exists id


alter table if exists outcome_analyses
drop column if exists non_inferiority_description,
drop column if exists param_type,
drop column if exists param_value,
drop column if exists dispersion_type,
drop column if exists dispersion_value,
drop column if exists outcome_analyses,
drop column if exists p_value_modifier,
drop column if exists p_value,
drop column if exists ci_n_sides,
drop column if exists ci_percent,
drop column if exists ci_lower_limit,
drop column if exists ci_upper_limit,
drop column if exists ci_upper_limit_na_comment,
drop column if exists p_value_description,
drop column if exists "method",
drop column if exists method_description,
drop column if exists estimate_description,
drop column if exists other_analysis_description,
drop column if exists groups_description,
drop column if exists ci_upper_limit_raw,
drop column if exists ci_lower_limit_raw,
drop column if exists p_value_raw,
drop column if exists id


alter table if exists responsible_parties
drop column if exists "name",
drop column if exists title,
drop column if exists organization,
drop column if exists affiliation,
drop column if exists old_name_title,
drop column if exists id


alter table if exists sponsors
drop column if exists "name",
drop column if exists id


alter table if exists facilities
drop column if exists status,
drop column if exists "name",
drop column if exists zip,
drop column if exists id


alter table if exists brief_summaries
drop column if exists id


alter table if exists conditions
drop column if exists id


alter table if exists interventions
drop column if exists id


alter table if exists detailed_descriptions
drop column if exists id


alter table if exists browse_conditions
drop column if exists id


alter table if exists browse_interventions
drop column if exists id


alter table if exists countries
drop column if exists id


/*
Объединение всех данных по исследованиям в одну таблицу
и сразу дополнительная фильтрация:
-по типу Interventional, 
-по статусу (C/T/W), 
-по году регистрации (>2010)
*/

/*enrollment,enrollment_type не использую для mvp, но потом можно подумать, чтобы их использовать как конечную фичу (степень недобора пациентов) 
 * expanded_access_type_individual,expanded_access_type_intermediate,expanded_access_type_treatment, has_dmc - пока тоже выкинула, но это нормальные фичи для полного обучения
 * con.downcase_name as conditions,
bc.downcase_mesh_term as downcase_mesh_term_condition,
bc.mesh_type as mesh_type_condition,
bi.downcase_mesh_term as downcase_mesh_term_interventions,
bi.mesh_type as mesh_type_interventions,
s.start_date - s.completion_date as duration_in_days, - не нужно, так как есть actual duration in calculated val
 * */

CREATE TABLE group_type AS
SELECT 
    nct_id,
    MAX(CASE WHEN group_type = 'Experimental' THEN 1 ELSE 0 END) AS Experimental_groups,
    MAX(CASE WHEN group_type = 'Active Comparator' THEN 1 ELSE 0 END) AS Active_Comparator_groups,
    MAX(CASE WHEN group_type = 'Placebo Comparator' THEN 1 ELSE 0 END) AS Placebo_Comparator_groups,
    MAX(CASE WHEN group_type = 'No Intervention' THEN 1 ELSE 0 END) AS No_Intervention_groups,
    MAX(CASE WHEN group_type = 'Other' THEN 1 ELSE 0 END) AS Other_groups,
    MAX(CASE WHEN group_type = 'Sham Comparator' THEN 1 ELSE 0 END) AS Sham_Comparator_groups
FROM design_groups
GROUP BY nct_id;


CREATE TABLE interventions_uni AS
SELECT DISTINCT nct_id, intervention_type
FROM interventions
WHERE intervention_type = 'Drug';


CREATE TABLE outcome_analyses_uni AS
SELECT DISTINCT nct_id, non_inferiority_type
FROM outcome_analyses;

CREATE TABLE outcome_analyses_unique AS
SELECT 
    nct_id,
    MAX(CASE WHEN non_inferiority_type = 'Superiority or Other' THEN 1 ELSE 0 END) AS superiority_or_other,
    MAX(CASE WHEN non_inferiority_type = 'Non-Inferiority or Equivalence' THEN 1 ELSE 0 END) AS non_inferiority_or_equivalence,
    MAX(CASE WHEN non_inferiority_type = 'Superiority' THEN 1 ELSE 0 END) AS superiority,
    MAX(CASE WHEN non_inferiority_type = 'Other' THEN 1 ELSE 0 END) AS other,
    MAX(CASE WHEN non_inferiority_type = 'Non-Inferiority or Equivalence (legacy)' THEN 1 ELSE 0 END) AS non_inferiority_or_equivalence_legacy,
    MAX(CASE WHEN non_inferiority_type = 'Superiority or Other (legacy)' THEN 1 ELSE 0 END) AS superiority_or_other_legacy,
    MAX(CASE WHEN non_inferiority_type = 'Non-Inferiority' THEN 1 ELSE 0 END) AS non_inferiority,
    MAX(CASE WHEN non_inferiority_type = 'Equivalence' THEN 1 ELSE 0 END) AS equivalence
FROM outcome_analyses_uni
GROUP BY nct_id;


/* SPONSORS*/
CREATE TABLE sponsors_unique AS
SELECT DISTINCT nct_id, agency_class
FROM sponsors

create table sponsors_unique_OHE as
select
	nct_id,
	MAX(CASE WHEN agency_class = 'OTHER' THEN 1 ELSE 0 END) AS OTHER,
	MAX(CASE WHEN agency_class = 'INDUSTRY' THEN 1 ELSE 0 END) AS INDUSTRY,
	MAX(CASE WHEN agency_class = 'NIH' THEN 1 ELSE 0 END) AS NIH,
	MAX(CASE WHEN agency_class = 'UNKNOWN' THEN 1 ELSE 0 END) AS UNKNOWN,
	MAX(CASE WHEN agency_class = 'FED' THEN 1 ELSE 0 END) AS FED,
	MAX(CASE WHEN agency_class = 'OTHER_GOV' THEN 1 ELSE 0 END) AS OTHER_GOV
FROM sponsors_unique
GROUP BY nct_id;	

select * from countries_number

create table countries_number as
SELECT 
    nct_id,
    COUNT(DISTINCT name) AS number_of_countries
FROM 
    countries
GROUP BY 
    nct_id;




CREATE TABLE studies_db AS
select
s.nct_id,
s.study_type as study_type,
s.brief_title as brief_title,
s.official_title as official_title,
s.overall_status as overall_status,
s.phase as phase,
s.number_of_arms as number_of_arms,
s.number_of_groups as number_of_groups,
s.has_expanded_access as has_expanded_access,
s.has_dmc as has_dmc,                							/*!!!!!! */
s.is_fda_regulated_drug as is_fda_regulated_drug,                /*!!!!!! */
s.source_class as source_class,
inter.intervention_type as intervention_type, 
bs.description as brief_summaries, 
dd.description as detailed_descriptions,
cal_val.number_of_facilities as number_of_facilities,
cal_val.registered_in_calendar_year as registered_in_calendar_year,
cal_val.actual_duration as actual_duration,
cal_val.has_us_facility as has_us_facility,
cal_val.has_single_facility as has_single_facility,
CASE cal_val.minimum_age_unit
	WHEN 'Day' THEN cal_val.minimum_age_num / 365.0
	WHEN 'Days' THEN cal_val.minimum_age_num / 365.0
	WHEN 'Hour' THEN cal_val.minimum_age_num / (365.0 * 24)
	WHEN 'Hours' THEN cal_val.minimum_age_num / (365.0 * 24)
	WHEN 'Minute' THEN cal_val.minimum_age_num / (365.0 * 24 * 60)
	WHEN 'Minutes' THEN cal_val.minimum_age_num / (365.0 * 24 * 60)
	WHEN 'Month' THEN cal_val.minimum_age_num / 12.0
	WHEN 'Months' THEN cal_val.minimum_age_num / 12.0
	WHEN 'Week' THEN cal_val.minimum_age_num / 52.0
	WHEN 'Weeks' THEN cal_val.minimum_age_num / 52.0
	WHEN 'Year' THEN cal_val.minimum_age_num
	WHEN 'Years' THEN cal_val.minimum_age_num
	ELSE NULL
END AS minimum_age_in_years,
CASE cal_val.maximum_age_unit
	WHEN 'Day' THEN cal_val.maximum_age_num / 365.0
	WHEN 'Days' THEN cal_val.maximum_age_num / 365.0
	WHEN 'Hour' THEN cal_val.maximum_age_num / (365.0 * 24)
	WHEN 'Hours' THEN cal_val.maximum_age_num / (365.0 * 24)
	WHEN 'Minute' THEN cal_val.maximum_age_num / (365.0 * 24 * 60)
	WHEN 'Minutes' THEN cal_val.maximum_age_num / (365.0 * 24 * 60)
	WHEN 'Month' THEN cal_val.maximum_age_num / 12.0
	WHEN 'Months' THEN cal_val.maximum_age_num / 12.0
	WHEN 'Week' THEN cal_val.maximum_age_num / 52.0
	WHEN 'Weeks' THEN cal_val.maximum_age_num / 52.0
	WHEN 'Year' THEN cal_val.maximum_age_num
	WHEN 'Years' THEN cal_val.maximum_age_num
	ELSE NULL
END AS maximum_age_in_years, 
cal_val.number_of_primary_outcomes_to_measure as number_of_primary_outcomes_to_measure,
cal_val.number_of_secondary_outcomes_to_measure as number_of_secondary_outcomes_to_measure,
cal_val.number_of_other_outcomes_to_measure as number_of_other_outcomes_to_measure,
des.allocation as allocation,
des.intervention_model as intervention_model,
des.masking as masking,
des.subject_masked as subject_masked,
des.caregiver_masked as caregiver_masked,
des.investigator_masked as investigator_masked,
des.outcomes_assessor_masked as outcomes_assessor_masked,
elig.sampling_method sampling_method, 
elig.gender as gender,
elig.healthy_volunteers as healthy_volunteers,
elig.criteria as criteria,
out_an.superiority_or_other as superiority_or_other,
out_an.non_inferiority_or_equivalence as non_inferiority_or_equivalence,
out_an.superiority as superiority,
out_an.other as other_sup_inf_type,
out_an.non_inferiority_or_equivalence_legacy as non_inferiority_or_equivalence_legacy,
out_an.superiority_or_other_legacy as superiority_or_other_legacy,
out_an.non_inferiority as non_inferiority,
out_an.equivalence as equivalence,
resp_p.responsible_party_type as responsible_party_type,
group_t.Experimental_groups as Experimental_groups,
group_t.Active_Comparator_groups as Active_Comparator_groups,
group_t.Placebo_Comparator_groups as Placebo_Comparator_groups,
group_t.No_Intervention_groups as No_Intervention_groups,
group_t.Other_groups as Other_groups,
group_t.Sham_Comparator_groups as Sham_Comparator_groups, 
coun.number_of_countries as number_of_countries,
spon.OTHER as Other_sponsor, 
spon.INDUSTRY as INDUSTRY, 
spon.NIH as NIH,
spon.FED as FED, 
spon.OTHER_GOV as OTHER_GOV
from studies s
left join interventions_uni inter on s.nct_id = inter.nct_id
left join brief_summaries bs on s.nct_id = bs.nct_id
left join detailed_descriptions dd on s.nct_id = dd.nct_id
left join calculated_values cal_val on s.nct_id = cal_val.nct_id
left join designs des on s.nct_id = des.nct_id
left join eligibilities elig on s.nct_id = elig.nct_id
left join outcome_analyses_unique out_an on s.nct_id = out_an.nct_id
left join sponsors_unique_OHE spon on s.nct_id = spon.nct_id
left join responsible_parties resp_p on s.nct_id = resp_p.nct_id
left join countries_number coun on s.nct_id = coun.nct_id
left join group_type group_t on s.nct_id = group_t.nct_id
WHERE 
    s.study_type = 'Interventional'
    AND s.overall_status IN ('Completed', 'Terminated', 'Withdrawn')

    
SELECT nct_id, COUNT(*) as count
FROM studies_db
GROUP BY nct_id
HAVING COUNT(*) > 1

select * from studies_db




/*cal_val.registered_in_calendar_year > '2010' 
 * fas.city as city, 
fas.state as state,
fas.country as country

left join facilities fas on s.nct_id = fas.nct_id
left join conditions con on s.nct_id = con.nct_id
left join browse_conditions bc on s.nct_id = bc.nct_id
left join interventions inter on s.nct_id = inter.nct_id
left join browse_interventions bi on s.nct_id = bi.nct_id
left join design_groups des_g on s.nct_id = des_g.nct_id
spon.agency_class as agency_class,
spon.lead_or_collaborator as lead_or_collaborator,


 * */

