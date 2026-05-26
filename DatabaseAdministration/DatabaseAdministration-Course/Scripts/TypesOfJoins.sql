CREATE TABLE [dbo].[Course](
	[CourseID] [int] NULL,
	[RollNO] [int] NULL
) ON [PRIMARY]

-----------------------------
CREATE TABLE [dbo].[Student](
	[RollNo] [int] NOT NULL,
	[StudentName] [nvarchar](50) NULL,
	[StudentCity] [nvarchar](20) NULL,
	[StudentPhoneNo] [nvarchar](50) NULL,
	[StuentAge] [int] NULL,
 CONSTRAINT [PK_Student] PRIMARY KEY CLUSTERED 
(
	[RollNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

--------------------------------------------------------

select * from [dbo].[Student]

-----------------------------------------------------

select * from [dbo].[Course]

 ------------------------------------------------

 select s.rollno,s.studentname,c.courseid from student s
 inner join course c
 on s.rollno = c.rollno

  select s.rollno,s.studentname,c.courseid from student s
 right join course c
 on s.rollno = c.rollno

  select s.rollno,s.studentname,c.courseid from student s
 left join course c
 on s.rollno = c.rollno

  select s.rollno,s.studentname,c.courseid from student s
 full join course c
 on s.rollno = c.rollno