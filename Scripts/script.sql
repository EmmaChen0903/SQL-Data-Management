use G1T1;

# Question 1
-- input by users
set @input_categories='crime prevention,public health';    # each category needs to be seperated by a single `,` only
set @input_start_month=6;		-- replace with the desired value
set @input_start_year=2022;		-- replace with the desired value
set @input_end_month=12;		-- replace with the desired value
set @input_end_year=2022;		-- replace with the desired value

-- SQL query
SELECT
    vo.VOID,
    vo.Name,
    COUNT(DISTINCT a_organize.Name) AS NumberOfActivitiesOrganized,
    COUNT(DISTINCT post.CreateDateTime) AS NumberOfPosts
FROM
    vo
    JOIN a_organize ON vo.VOID = a_organize.VOID
    JOIN activity ON a_organize.Name = activity.Name AND a_organize.Date = activity.Date
    JOIN act_category ON activity.Name = act_category.Name AND activity.Date = act_category.Date
    JOIN post ON a_organize.Name = post.Name AND a_organize.Date = post.Date AND a_organize.VOID = post.VOID
WHERE
	act_category.Category in (
    SUBSTRING_INDEX(@input_categories, ',', 1), 
    SUBSTRING_INDEX(@input_categories, ',', 2),
    SUBSTRING_INDEX(@input_categories, ',', 3), 
    SUBSTRING_INDEX(@input_categories, ',', 4), 
    SUBSTRING_INDEX(@input_categories, ',', 5), 
    SUBSTRING_INDEX(@input_categories, ',', 6), 
    SUBSTRING_INDEX(@input_categories, ',', 7), 
    SUBSTRING_INDEX(@input_categories, ',', 8), 
    SUBSTRING_INDEX(@input_categories, ',', 9), 
    SUBSTRING_INDEX(@input_categories, ',', 10), 
    SUBSTRING_INDEX(@input_categories, ',', -1)
    )
    AND DATE_FORMAT(activity.Date,'%Y-%m') >= DATE_FORMAT(CONCAT(@input_start_year, '-', @input_start_month, '-01'), '%Y-%m')
    AND DATE_FORMAT(activity.Date,'%Y-%m') <= DATE_FORMAT(CONCAT(@input_end_year, '-', @input_end_month, '-01'), '%Y-%m')
GROUP BY
    vo.VOID,
    vo.Name
ORDER BY
    vo.VOID ASC;
    

# Question 2
SET @Q2_input_mth = 3;    -- replace with the desired value
SET @Q2_input_yr = 2023;  -- replace with the desired value

SELECT
    ru.AcctName,
    user.Name,
    COUNT(register.Name) AS NumberOfActivitiesVolunteered,
    SUM(CASE WHEN register.Completed = 1 THEN 1 ELSE 0 END) AS NumberOfCompletedActivities,
    SUM(CASE WHEN register.Completed = 1 THEN register.NumHrs ELSE 0 END) AS HoursCompleted
FROM
    ru
    JOIN user ON ru.AcctName = user.AcctName
    LEFT JOIN affiliation ON ru.AcctName = affiliation.AcctName
    LEFT JOIN register ON ru.AcctName = register.AcctName AND affiliation.VOID = register.VOID
    LEFT JOIN activity ON register.Name = activity.Name AND register.Date = activity.Date
WHERE
    MONTH(activity.Date) = @Q2_input_mth 
    AND YEAR(activity.Date) = @Q2_input_yr
GROUP BY
    ru.AcctName,
    user.Name
ORDER BY
    HoursCompleted DESC;
    
# Question 3
DELIMITER $$

CREATE PROCEDURE GetRUDetails(IN inputAcctName VARCHAR(30))
BEGIN
    SELECT
        ru.AcctName AS AccountName,
        user.Name,
        ru.HighestEdQual AS HighestQualification,
        COUNT(DISTINCT affiliation.VOID) AS NumberOfAffiliations,
        COUNT(DISTINCT given.Name) AS NumberOfAwardsReceived,
        COUNT(DISTINCT register.Name) AS NumberOfActivitiesVolunteered,
        SUM(register.NumHrs) AS NumberOfVolunteeringHoursCompleted
    FROM
        ru
        JOIN user ON ru.AcctName = user.AcctName
        LEFT JOIN affiliation ON ru.AcctName = affiliation.AcctName
        LEFT JOIN given ON ru.AcctName = given.AcctName
        LEFT JOIN register ON ru.AcctName = register.AcctName AND affiliation.VOID = register.VOID
    WHERE
        ru.AcctName = inputAcctName
    GROUP BY
        ru.AcctName,
        user.Name,
        ru.HighestEdQual;
END $$

DELIMITER ;

CALL GetRUDetails('amy.henderson.224');

# Question 4
SET @X := 12; -- Replace 12 with the desired value of X
SET @prev_awards := NULL;
SET @curr_rank := 1;

SELECT
	AcctName,
    Name,
    NumberOfAwards
FROM
	(SELECT
		RankedUsers.AcctName,
		RankedUsers.Name,
		RankedUsers.NumberOfAwards,
        # Get the rank
		@curr_rank := if(RankedUsers.Pre_award=RankedUsers.NumberOfAwards
						OR RankedUsers.Pre_award is null,
						@curr_rank,
						@curr_rank + 1) as "Rank"
	FROM (
		SELECT
			ru.AcctName,
			user.Name,
			COUNT(given.Name) AS NumberOfAwards,
            # Add the numOfReward from last row to a new column
            # the first row value should be null
			@prev_awards := lag(COUNT(given.Name)) OVER (ORDER BY COUNT(given.Name) DESC) as Pre_award
		FROM
			ru
			JOIN user ON ru.AcctName = user.AcctName
			LEFT JOIN given ON ru.AcctName = given.AcctName
		GROUP BY
			ru.AcctName,
			user.Name
		ORDER BY
			NumberOfAwards DESC
	) AS RankedUsers
	WHERE
		@curr_rank  < @X
	) AS Final
Order by NumberOfAwards DESC;
    
# Question 5
-- Set the input month and year
SET @input_month := 6;
SET @input_year := 2022;

-- Calculate the start and end dates for the 3-month range
SET @start_date := CONCAT(@input_year, '-', @input_month, '-01');
SET @end_date := DATE_ADD(@start_date, INTERVAL 3 MONTH);

SELECT
    course.ID,
    course.Name,
    course.Description,
    run.StartDate,
    run.EndDate,
    endorsement.Endorser AS Endorser,
    endorsement.Date AS EndorsementDate
    
FROM
    course
    JOIN run ON course.ID = run.ID
    LEFT JOIN endorsement ON course.ID = endorsement.ID
WHERE
    run.StartDate >= @start_date AND run.StartDate < @end_date
ORDER BY
    course.ID,
    run.StartDate,
    endorsement.Date;

# Question 6
-- Set the input partial name
SET @input_name := 'Ben'; -- Replace Ben with the desired value of input_name
SELECT
	user.AcctName,
    user.Name,
    user.UserType,
    user.PrimaryTel,
    user.PrimaryTelType,    
    vo.Name AS VOName,
    SUM(register.NumHrs) AS HoursVolunteered 
FROM
    user
    LEFT JOIN voa ON user.AcctName = voa.AcctName
    LEFT JOIN affiliation ON user.AcctName = affiliation.AcctName
    LEFT JOIN register ON user.AcctName = register.AcctName AND affiliation.VOID = register.VOID
    LEFT JOIN vo ON if(user.UserType="RU",vo.VOID = affiliation.VOID,vo.VOID = voa.VOID)
WHERE user.Name LIKE CONCAT('%', @input_name, '%')
GROUP BY 
	user.AcctName, user.Name, user.PrimaryTel, user.PrimaryTelType, user.UserType, vo.Name
ORDER BY
	user.UserType DESC, user.Name ASC, HoursVolunteered DESC;

# Question 7
# create rank table for EduQualification
CREATE TABLE EduQualification
(
edu_rank INT NOT NULL, 
QUALIFICATION VARCHAR(20) NOT NULL,
CONSTRAINT EduQual_pk PRIMARY KEY(edu_rank)
);
# insert qualicifations into table
insert into EduQualification values (1, 'Certificate');
insert into EduQualification values (2, 'Diploma');
insert into EduQualification values (3, 'Degree');
insert into EduQualification values (4, 'Postgraduate degree');

-- set input variables
SET @input_date = '2023-12-01';
SET @ru_account = 'cas.duran.250';

-- SQL
-- with accounts of null category
WITH user_act AS (
  SELECT
    ru.acctname,
    ru.HighestEdQual,
    IFNULL(EduQualification.edu_rank, 0) AS ru_rank,
    category
  FROM
    ru
    LEFT JOIN interest ON ru.acctname = interest.acctname
    LEFT JOIN EduQualification ON ru.HighestEdQual = EduQualification.QUALIFICATION
  -- filter by RU acct name
  WHERE
    ru.acctname = @ru_account
),
-- with activity and its qualification rank
act_qualification AS (
  SELECT
    category,
    activity.name,
    activity.Date,
    IFNULL(edu_rank, 0) AS act_rank,
    MinReqEd
  FROM
    act_category,
    activity
    LEFT JOIN EduQualification ON activity.MinReqEd = EduQualification.QUALIFICATION
  WHERE
    act_category.name = activity.name
    -- filter by input date
    AND act_category.date > @input_date
)
-- combine
SELECT
  name AS 'Activity Name',
  Date AS 'Activity Date',
  MinReqEd AS 'Minimum Edu Qualification',
  GROUP_CONCAT(act_qualification.category) AS 'Categories'
FROM
  user_act,
  act_qualification
-- compare interest and category, if null then take all
WHERE
  (user_act.category IS NULL OR user_act.category = act_qualification.category)
  -- compare min.education and RU's education, if min education null then RU take all
  AND (MinReqEd IS NULL OR ru_rank >= act_rank)
GROUP BY
  name,
  Date,
  MinReqEd;



