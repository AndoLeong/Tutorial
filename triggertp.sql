--Le nombre dans espece est en norme avec le nombre d'individu de la meme espece
CREATE TRIGGER nbEspInd
AFTER INSERT or UPDATE ON Individu
FOR EACH STATEMENT
DECLARE 
nbrInd INTEGER,
CodeIndex INTEGER,
BEGIN
SELECT CodeEspece INTO CodeIndex,Count(*) INTO nbrInd from Individu GROUP BY CodeEspece;
IF(CodeIndex=Espece.CodeEspece AND nbrInd>1 AND Espece.Nombre<2)THEN
	UPDATE Espece Set Nombre=nbrInd
ENDIF
IF(CodeIndex=Espece.CodeEspece AND nbrInd=1)THEN
	UPDATE Espece Set Nombre= NULL
ENDIF;
END;
/
--L'espece des parents est la meme que celle de l'enfant 
CREATE TRIGGER memeEspeceParents
BEFORE INSERT ON Individu
FOR EACH ROW
DECLARE 
codeEstPere INTEGER,
codeEstMere INTEGER,
BEGIN
Select CodeEspece INTO codeEstPere FROM Individu WHERE new.Pere = CodeIndividu;
Select CodeEspece INTO codeEstMere FROM Individu WHERE new.Mere = CodeIndividu;

if(codeEstPere = codeEstMere and new.CodeEspece <> codeEstPere)THEN
	RAISE_APPLICATION_ERROR(-20003,'');
ENDIF;
END;
/
--S'il est ne dans le zoo alors il a un pere et une mere 
CREATE TRIGGER aUnPereEtMere 
AFTER INSERT ON Individu
FOR EACH ROW
BEGIN
if(EXISTS(SELECT Pere FROM Individu where new.CodeIndividu = CodeIndividu))
and
(NOT EXISTS (SELECT Mere FROM Individu where new.CodeIndividu = CodeIndividu))THEN
	RAISE_APPLICATION_ERROR(-20003,'');
ENDIF;
END;
/
--Il doit etre mort apres qu'il soit ne
CREATE TRIGGER datEND
BEFORE INSERT OR UPDATE OF DateDeces,DateNaissance ON Individu
FOR EACH ROW 
BEGIN 
if(EXISTS(new.DateDeces)AND EXISTS(new.DateNaissance))AND ((new.DateDeces-new.DateNaissance)<0)THEN 
	RAISE_APPLICATION_ERROR(-20003,'');
ENDIF;
END ;
/
--Les dates de naissance (et de décès éventuels) des parents (s'ils existent) 
--de chaque individu sont cohérentes, respectivement antérieures et postérieures
-- (avec une marge d’un an pour tenir compte du délai de fécondité et du temps 
--de gestation), avec la date de naissance de l'individu.
CREATE TRIGGER logiqueDate
BEFORE INSERT OR UPDATE ON Individu
FOR EACH ROW 
DECLARE
DateNaissancePere DATE,
DateDecesPere Date,
DateNaissanceMere DATE,
DateDecesMere Date,
BEGIN 
SELECT (DateNaissance INTO DateNaissancePere FROM (SELECT Pere FROM Individu where new.CodeIndividu = CodeIndividu););
SELECT (DateDeces INTO DateDecesPere FROM (SELECT Pere FROM Individu where new.CodeIndividu = CodeIndividu););
SELECT (DateNaissance INTO DateNaissanceMere FROM (SELECT Mere FROM Individu where new.CodeIndividu = CodeIndividu););
SELECT (DateDeces INTO DateDecesMere FROM (SELECT Mere FROM Individu where new.CodeIndividu = CodeIndividu););
SELECT DateNaissanceMere + interval '1' year AS PeriodGestMere  from Individu;
SELECT DateNaissancePere + interval '1' year AS PeriodGestPere  from Individu;
--il manque encore 
IF(new.DateNaissance<PeriodGestMere OR new.DateNaissance<PeriodGestPere	OR new.DateNaissance>DateDecesMere)THEN
	RAISE_APPLICATION_ERROR(-20003,'');
ENDIF;
END;
/
--Sa mesure doit etre prise dans un ordre chronologique
CREATE TRIGGER VerifDateMesure
BEFORE INSERT or UPDATE of DateMesure ON Mesure
FOR EACH ROW
BEGIN
if(new.CodeIndividu = CodeIndividu and new.DateMesure <= DateMesure)THEN
    RAISE_APPLICATION_ERROR(-20003,'');
ENDIF;
END;
/