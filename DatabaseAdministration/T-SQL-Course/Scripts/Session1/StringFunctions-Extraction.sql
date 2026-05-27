DECLARE @chrASCII as varchar(10) = '  hello  '
DECLARE @chrUNICODE as varchar(10) = N'helloζ'

select left(@chrASCII,2) as myASCII,
right(@chrUNICODE,2) as myUNICODE,
substring(@chrASCII,3,2) as midletters,
ltrim(rtrim(@chrASCII)) as trim,
replace(@chrASCII,'l','L') as Replace,
upper(@chrASCII) as myUpper,
lower(@chrASCII) as myLower