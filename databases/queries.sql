
-- Books
select *
 from book
where title like '%Tagalog%'
order by title;

select * from book order by changeDate desc;


-- Books with certain keywords
select *
 from book
where idbook in (
	select distinct idbook
	 from keyword
	where keyword like '%Philippines%'
);


-- Authors (1)
select *
  from book
 where author like '%Bonger%'
order by author;


-- People
select p.idbook, p.key, p.dates, p.role, p.viaf, b.title
  from person p
  join book b on b.idbook = p.idbook
 where name like 'William%'
order by `key`;


-- People without a key
select p.idbook, p.name, p.dates, p.role, p.viaf, b.author, b.title
  from person p
  join book b on b.idbook = p.idbook
 where p.key is null or p.key = ''
order by p.idbook;


-- Variants of words
select w.word, w.language, w.count, b.title, b.author from word w
 join book b on b.idbook = w.idbook
 where language = 'en' and word in ('fault-finders', 'faultfinders')
 order by b.idbook;


-- Distinct roles
select role, count(role) from person group by role;


-- Books with word-counts
select idbook, author, title,
 (select count(*) from word where word.idbook = book.idbook) as distinct_words,
 (select sum(count) from word where word.idbook = book.idbook) as total_words,
 (select count(distinct(language)) from word where word.idbook = book.idbook) as distinct_languages
 from book
 -- where title like 'lord%'
 order by idbook desc;


-- Words per language
select
    language,
    count(1) as distinct_words,
    sum(count) as total_words
from word w1 group by language
order by distinct_words desc;


-- Consolidate persons based on viaf ID
select min(`key`), min(name), regexp_substr(viaf, '[0-9]+') as viafId, count(*) as occurances, group_concat(distinct role)
  from person
 where `key` is not null and `key` <> ''
group by viaf
order by `key`;


-- Find words in old-orthography Dutch that occur more than X times in Y different works
select word, sum(count), sum(1) from word
 where language = 'nl-1900'
group by word collate utf8mb4_bin
having sum(count) > 50 and sum(1) > 10
order by sum(count) desc;


-- Find words in old-orthography Dutch that do not occur in the spelling list (the book with id 22722).
select word, sum(count), sum(1)
from word
where
    language = 'nl-1900'
    and word not in (select w2.word from word w2 where w2.idbook = 22722 and language = 'nl-1900')
group by word collate utf8mb4_bin
  having sum(count) > 50 and sum(1) > 10;




