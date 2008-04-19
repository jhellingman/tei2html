
-- Words in the old list, joined with frequency information if available
select ISNULL(wordcount, 0) as wcount, ISNULL(documentcount, 0) as dcount, ow.word, ISNULL(left(modernword, 32), '~') as modernword 
	from OldWords ow LEFT JOIN Words w ON ow.word = w.word  
	order by wordcount DESC, ow.word

-- Words in the new list, joined with frequency information if available
select ISNULL(wordcount, 0) as wcount, ISNULL(documentcount, 0) as dcount, ow.word 
	from NewWords ow LEFT JOIN Words w ON ow.word = w.word  
	order by wordcount DESC, ow.word

-- Very long words
select max(len(word)) from Words
select word from Words where len (word)> 32 
	and word not like '%-%'
	order by len(word)

select max(len(word)) from NewWords
select word from NewWords where len (word)> 32 
	order by len(word)



-- Versch -> Versche
select LEFT(w1.word, 24), w1.wordcount, LEFT(w2.word, 24), w2.wordcount 
	from Words w1, Words w2 
	where w1.modernword is not null and 
		w2.modernword is not null and
		LEN(w1.word) > 2 and 
		w2.word = w1.word + 'e' and 
		w1.wordcount > 7 and
		w2.wordcount > 7
	order by w1.wordcount DESC

-- Versch -> Versche -> Verschen
select LEFT(w1.word, 24), w1.wordcount, LEFT(w2.word, 24), w2.wordcount, LEFT(w3.word, 24), w3.wordcount 
	from Words w1, Words w2, Words w3 
	where w1.modernword is not null and 
		w2.modernword is not null and
		LEN(w1.word) > 2 and 
		w2.word = w1.word + 'e' and 
		w3.word = w1.word + 'en' and
		w1.wordcount > 7 and
		w2.wordcount > 7 and
		w3.wordcount > 7
	order by w1.word, w1.wordcount DESC, w2.wordcount  DESC, w3.wordcount  DESC


-- Breed -> Brede; Schraal -> Schrale
select w2.word, w2.wordcount, w1.word, w1.wordcount 
	from Words w1, Words w2 
	where w1.modernword is not null and 
		w2.modernword is not null and
		-- w1.word <> w1.modernword and
		LEN(w1.word) > 2 and
		SUBSTRING(w2.word, LEN(w2.word) - 1, 1) = SUBSTRING(w2.word, LEN(w2.word) - 2, 1) and
		w1.word =  SUBSTRING(w2.word, 1, LEN(w2.word) - 2) + SUBSTRING(w2.word, LEN(w2.word), 1) + 'e' and 
		w2.wordcount > 7 and
		w1.wordcount > 7
	order by w1.word

-- Lees -> Leze; Geef -> Geve

DROP PROC scannos
GO

CREATE PROC scannos @a char(4), @b char(4) 
AS 
select w1.word, w1.wordcount, w2.word, w2.wordcount 
	from Words w1, Words w2 
	where w1.modernword is not null and 
	        w2.modernword is not null and
		replace(w2.word, @a, @b) = replace(w1.word, @a, @b) and
		w1.word <> w2.word
	order by w1.wordcount DESC
GO


EXEC scannos 'b', 'h'
GO


DROP PROC scannos2
GO

CREATE PROC scannos2 @a0 char(4), @b0 char(4) 
AS 
declare @a char(4)
declare @b char(4)
set @a = @a0
set @b = @b0
select ow1.word, w1.wordcount, ow2.word, w2.wordcount
	from (OldWords ow1 left join Words w1 on ow1.word = w1.word),
	 	(OldWords ow2 left join Words w2 on ow2.word = w2.word)
	where 
		replace(w2.word, @a, @b) = replace(w1.word, @a, @b) and
		w1.word <> w2.word
GO


EXEC scannos2 'b', 'h'
GO



-- Scanno finding  b - h
select LEFT(w1.word, 24), w1.wordcount, LEFT(w2.word, 24), w2.wordcount 
	from Words w1, Words w2 
	where w1.modernword is not null and 
		w2.modernword is not null and
		replace(w2.word, 'b', 'h') = replace(w1.word, 'b', 'h') and
		w1.word <> w2.word
		and w1.wordcount >= w2.wordcount
	order by w1.wordcount DESC

-- Scanno finding  c - e
select LEFT(w1.word, 24), w1.wordcount, LEFT(w2.word, 24), w2.wordcount 
	from Words w1, Words w2 
	where w1.modernword is not null and 
		w2.modernword is not null and
		replace(w2.word, 'c', 'e') = replace(w1.word, 'c', 'e') and
		w1.word <> w2.word
		and w1.wordcount >= w2.wordcount
	order by w1.wordcount DESC

-- Scanno finding  C - G
select LEFT(w1.word, 24), w1.wordcount, LEFT(w2.word, 24), w2.wordcount 
	from Words w1, Words w2 
	where w1.modernword is not null and 
		w2.modernword is not null and
		replace(w2.word, 'C', 'G') = replace(w1.word, 'C', 'G') and
		w1.word <> w2.word
		and w1.wordcount >= w2.wordcount
	order by w1.wordcount DESC

-- Scanno finding  f - t
select LEFT(w1.word, 24), w1.wordcount, LEFT(w2.word, 24), w2.wordcount 
	from Words w1, Words w2 
	where w1.modernword is not null and 
		w2.modernword is not null and
		replace(w2.word, 'f', 't') = replace(w1.word, 'f', 't') and
		w1.word <> w2.word
		and w1.wordcount >= w2.wordcount
	order by w1.wordcount DESC

-- Scanno finding  Gr - G
select LEFT(w1.word, 24), w1.wordcount, LEFT(w2.word, 24), w2.wordcount 
	from Words w1, Words w2 
	where w1.modernword is not null and 
		w2.modernword is not null and
		replace(w2.word, 'Gr', 'G') = replace(w1.word, 'Gr', 'G') and
		w1.word <> w2.word
		and w1.wordcount >= w2.wordcount
	order by w1.wordcount DESC

-- Scanno finding  h - li
select LEFT(w1.word, 24), w1.wordcount, LEFT(w2.word, 24), w2.wordcount 
	from Words w1, Words w2 
	where w1.modernword is not null and 
		w2.modernword is not null and
		replace(w2.word, 'h', 'li') = replace(w1.word, 'h', 'li') and
		w1.word <> w2.word
		and w1.wordcount >= w2.wordcount
	order by w1.wordcount DESC

-- Scanno finding  in - m
select LEFT(w1.word, 24), w1.wordcount, LEFT(w2.word, 24), w2.wordcount 
	from Words w1, Words w2 
	where w1.modernword is not null and 
		w2.modernword is not null and
		replace(w2.word, 'in', 'm') = replace(w1.word, 'in', 'm') and
		w1.word <> w2.word
		and w1.wordcount >= w2.wordcount
	order by w1.wordcount DESC

-- Scanno finding  m - ni
select LEFT(w1.word, 24), w1.wordcount, LEFT(w2.word, 24), w2.wordcount 
	from Words w1, Words w2 
	where w1.modernword is not null and 
		w2.modernword is not null and
		replace(w2.word, 'm', 'ni') = replace(w1.word, 'm', 'ni') and
		w1.word <> w2.word
		and w1.wordcount >= w2.wordcount
	order by w1.wordcount DESC

-- Scanno finding  m - rn
select LEFT(w1.word, 24), w1.wordcount, LEFT(w2.word, 24), w2.wordcount 
	from Words w1, Words w2 
	where w1.modernword is not null and 
		w2.modernword is not null and
		replace(w2.word, 'm', 'rn') = replace(w1.word, 'm', 'rn') and
		w1.word <> w2.word
		and w1.wordcount >= w2.wordcount
	order by w1.wordcount DESC

-- Scanno finding  n - u
select LEFT(w1.word, 24), w1.wordcount, LEFT(w2.word, 24), w2.wordcount 
	from Words w1, Words w2 
	where w1.modernword is not null and 
		w2.modernword is not null and
		replace(w2.word, 'n', 'u') = replace(w1.word, 'n', 'u') and
		w1.word <> w2.word
		and w1.wordcount >= w2.wordcount
	order by w1.wordcount DESC






-- Scratch book
select * from Words where modernword is not null and wordcount > 20 and modernword <> word

select top 1000 * from Words order by wordcount DESC

select * from Words where wordcount = documentcount order by wordcount DESC


select * from Words where word like 'heeft'

select * from Dyads where count > 10 order by count DESC
select max(count) from Dyads

select * from Dyads where first='hij' or first='bij' order by second
select * from Dyads where second='hij' or second='bij' order by first

select left(d1.first, 3), left(d1.second, 20), d1.count, 
        	left(d2.first, 3), left(d2.second, 20), d2.count,
	        cast (d1.count as numeric) / cast (d2.count as numeric) as ratio
	from Dyads d1, Dyads d2 
	where d1.second = d2.second and 
		d1.first='hij' and d2.first = 'bij' 
	order by ratio DESC

select left(d1.first, 3), left(d1.second, 20), d1.count, 
        	left(d2.first, 3), left(d2.second, 20), d2.count,
	        cast (d1.count as numeric) / cast (d2.count as numeric) as ratio
	from Dyads d1, Dyads d2 
	where d1.second = d2.second and 
		d1.first='zon' and d2.first = 'zou' 
	order by ratio DESC

select left(d1.first, 3), left(d1.second, 20), d1.count, 
        	left(d2.first, 4), left(d2.second, 20), d2.count,
	        cast (d1.count as numeric) / cast (d2.count as numeric) as ratio
	from Dyads d1, Dyads d2 
	where d1.second = d2.second and 
		d1.first='met' and d2.first = 'niet' 
	order by ratio DESC


select * from Dyads where first='heeft' or first='beeft' order by count DESC

select * from Dyads where first='zon' or first='zou' order by count DESC


DROP PROC dyadscanno
GO 

CREATE PROC scannofrequency @a char(32), @b char(32) 
AS 
select @a first, left(d1.second, 20) second, d1.count, 
       @b first, left(d2.second, 20) second, d2.count,
       cast (d1.count as numeric) / cast (d2.count as numeric) as ratio
		from Dyads d1, Dyads d2 
		where d1.second = d2.second and d1.first = @a and d2.first = @b 
		order by ratio DESC
GO

CREATE PROC scannofrequency2 @a char(32), @b char(32) 
AS 
select left(d1.first, 20) first, @a second, d1.count, 
       left(d2.first, 20) first, @b second, d2.count,
       cast (d1.count as numeric) / cast (d2.count as numeric) as ratio
		from Dyads d1, Dyads d2 
		where d1.first = d2.first and d1.second = @a and d2.second = @b 
		order by ratio DESC
GO


EXEC scannofrequency 'hij', 'bij'
EXEC scannofrequency2 'hij', 'bij'
EXEC scannofrequency 'met', 'niet'
EXEC scannofrequency 'zou', 'zon'
EXEC scannofrequency 'het', 'hef'