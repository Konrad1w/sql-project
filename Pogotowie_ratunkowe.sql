DROP DATABASE [Pogotowie ratunkowe]
GO

CREATE DATABASE [Pogotowie ratunkowe]
GO

USE [Pogotowie ratunkowe]
GO


---------------------------------------------------


CREATE TABLE Osoby(
	IDosoby INT IDENTITY(1,1) PRIMARY KEY,
	Imiê NVARCHAR(50) NOT NULL,
	Nazwisko NVARCHAR(50) NOT NULL,
	[Data urodzenia] DATE NOT NULL,
	[Adres zamieszkania] NVARCHAR(50) NOT NULL,
	Narodowoœæ NVARCHAR(50),
	P³eæ NVARCHAR(1) NOT NULL,
	CHECK(P³eæ IN('M','K'))
)

CREATE TABLE Pracownicy (
	IDpracownika INT REFERENCES Osoby(IDosoby) PRIMARY KEY,
	DataZatrudnienia DATE NOT NULL,
	Specjalizacja NVARCHAR(50) NOT NULL,
	LiczbaDniUrlopu INT -- dni pozosta³e do wykorzystania
	CHECK(LiczbaDniUrlopu > 0) 
)

CREATE TABLE Pacjenci(
	IDpacjenta INT REFERENCES Osoby(IDosoby) PRIMARY KEY,
	PESEL INT UNIQUE NOT NULL,
	Ubezpieczenie NVARCHAR(3) NOT NULL,
	CHECK(Ubezpieczenie IN('TAK','NIE'))
)

CREATE TABLE [Dane przegl¹du technicznego](
	[IDgrupy marki karetki] INT PRIMARY KEY,
	[Data produkcji] DATE NOT NULL,
	[Data zakupu] DATE NOT NULL
)
 
CREATE TABLE Karetki(
	IDkaretki INT PRIMARY KEY,
	[IDgrupy marki karetki] INT FOREIGN KEY REFERENCES [Dane przegl¹du technicznego]([IDgrupy marki karetki])
	ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
	Dostêpnoœæ NVARCHAR(3),
	CHECK(Dostêpnoœæ IN('TAK','NIE')),
	Nr_rejestracyjny NVARCHAR(10) UNIQUE NOT NULL,
	[Data przegl¹du technicznego] DATE NOT NULL
)

CREATE TABLE [Zespo³y ratownicze] (
	IDzespo³u INT PRIMARY KEY,
	RodzajZespo³u NVARCHAR(20) NOT NULL CHECK(RodzajZespo³u IN ('podstawowy', 'specjalny')),
	IDkaretki INT FOREIGN KEY REFERENCES Karetki(IDkaretki) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
	LiczbaDniPracy INT NOT NULL -- tygodniowo
)

CREATE TABLE [Zespo³y podstawowe] (
	[IDzespo³u podstawowego] INT PRIMARY KEY,
	IDpracownika1 INT NOT NULL,
	IDpracownika2 INT NOT NULL,
	IDpracownika3 INT NOT NULL
	FOREIGN KEY ([IDzespo³u podstawowego]) REFERENCES [Zespo³y ratownicze] (IDzespo³u) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (IDpracownika1) REFERENCES Pracownicy (IDpracownika),
	FOREIGN KEY (IDpracownika2) REFERENCES Pracownicy (IDpracownika),
	FOREIGN KEY (IDpracownika3) REFERENCES Pracownicy (IDpracownika) 
)

CREATE TABLE [Zespo³y specjalne] (
	[IDzespo³u specjalnego] INT PRIMARY KEY,
	IDpracownika1 INT NOT NULL,
	IDpracownika2 INT NOT NULL,
	IDpracownika3 INT NOT NULL,
	IDpracownika4 INT NOT NULL,
	FOREIGN KEY ([IDzespo³u specjalnego]) REFERENCES [Zespo³y ratownicze] (IDzespo³u) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (IDpracownika1) REFERENCES Pracownicy (IDpracownika),
	FOREIGN KEY (IDpracownika2) REFERENCES Pracownicy (IDpracownika),
	FOREIGN KEY (IDpracownika3) REFERENCES Pracownicy (IDpracownika), 
	FOREIGN KEY (IDpracownika4) REFERENCES Pracownicy (IDpracownika) 
)

CREATE TABLE [Nieobecnoœci pracowników] (
	IDpracownika INT,
	PowódNieobecnoœci NVARCHAR(20) NOT NULL CHECK(PowódNieobecnoœci IN ('urlop', '[zwolnienie lekarskie]')),
	DataRozpoczêcia DATE,
	DataZakoñczenia DATE NOT NULL
	PRIMARY KEY (IDpracownika, DataRozpoczêcia),
	FOREIGN KEY (IDpracownika) REFERENCES Pracownicy (IDpracownika) ON DELETE CASCADE ON UPDATE CASCADE
)

CREATE TABLE Urlopy (
	IDpracownika INT,
	DataRozpoczêcia DATE,
	TypUrlopu NVARCHAR(20) NOT NULL CHECK(TypUrlopu IN ('p³atny', 'bezp³atny'))
	PRIMARY KEY (IDpracownika, DataRozpoczêcia),
	FOREIGN KEY (IDpracownika, DataRozpoczêcia)
	REFERENCES [Nieobecnoœci pracowników] (IDpracownika, DataRozpoczêcia) 
	ON DELETE CASCADE ON UPDATE CASCADE
)

CREATE TABLE [Zwolnienia lekarskie] (
	IDpracownika INT,
	DataRozpoczêcia DATE,
	NrZwolnieniaLekarskieGO INT NOT NULL
	PRIMARY KEY (IDpracownika, DataRozpoczêcia),
	FOREIGN KEY (IDpracownika, DataRozpoczêcia)
	REFERENCES [Nieobecnoœci pracowników] (IDpracownika, DataRozpoczêcia) 
	ON DELETE CASCADE ON UPDATE CASCADE
)

CREATE TABLE Harmonogram (
	IDdy¿uru INT PRIMARY KEY,
	DzieñTygodnia NVARCHAR(15),
	GodzinaRozpoczêcia TIME,
	GodzinaZakoñczenia TIME,
	CHECK(GodzinaRozpoczêcia < GodzinaZakoñczenia),
	IDzespo³u1 INT FOREIGN KEY REFERENCES [Zespo³y ratownicze] (IDzespo³u) NOT NULL,
	IDzespo³u2 INT FOREIGN KEY REFERENCES [Zespo³y ratownicze] (IDzespo³u) NOT NULL
	UNIQUE (IDdy¿uru, DzieñTygodnia)
)

CREATE TABLE [Wynagrodzenie pracowników](
	Specjalizacja NVARCHAR(50) PRIMARY KEY,
	[Kwota wynagrodzenia] MONEY NOT NULL
)

CREATE TABLE Wezwania(
	IDwezwania INT PRIMARY KEY,
	IDpacjenta INT FOREIGN KEY REFERENCES Pacjenci(IDpacjenta) ON UPDATE CASCADE ON DELETE CASCADE UNIQUE NOT NULL,
	IDzespo³u INT FOREIGN KEY REFERENCES [Zespo³y ratownicze](IDzespo³u) NOT NULL,
	Nr_telefonu NVARCHAR(9) NOT NULL,
	CHECK (Nr_telefonu NOT LIKE '%[^0-9]%'),
	[Miejsce wezwania] NVARCHAR(50) NOT NULL,
	[Powód wezwania] NVARCHAR(50)
)

CREATE TABLE [Udzielana pomoc](
	IDwezwania INT FOREIGN KEY REFERENCES Wezwania(IDwezwania) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
	Diagnoza NVARCHAR(50) NOT NULL,
	[Liczba opatrunków] INT NOT NULL,
	[Cena opatrunku] MONEY NOT NULL,
	[Liczba par rêkawiczek] INT NOT NULL,
	[Cena pary rêkawiczek] MONEY NOT NULL,
	[Liczba kocy termicznych] INT NOT NULL,
	[Cena koca termicznego] MONEY NOT NULL,
	[Liczba resuscytatorów] INT NOT NULL,
	[Cena resuscytatora] MONEY NOT NULL,
	[Liczba stabilizatorów] INT NOT NULL,
	[Cena stabilizatora] MONEY NOT NULL,
	[Poniesione koszty] MONEY NOT NULL
)

CREATE TABLE Cennik(
	[Cena opatrunku] MONEY NOT NULL,
	[Cena pary rêkawiczek] MONEY NOT NULL,
	[Cena koca termicznego] MONEY NOT NULL,
	[Cena resuscytatora] MONEY NOT NULL,
	[Cena stabilizatora] MONEY NOT NULL
)

-------------------------------------------------------------

GO
CREATE VIEW [Pracownik pacjent] AS
	SELECT * FROM Osoby O
	JOIN Pracownicy PR ON O.IDosoby = PR.IDpracownika
	JOIN Pacjenci PA ON PR.IDpracownika = PA.IDpacjenta

GO
CREATE VIEW [Brak nieobecnoœci] AS
	SELECT * FROM Osoby O JOIN Pracownicy P ON O.IDosoby = P.IDpracownika
	WHERE O.IDosoby NOT IN (
		SELECT IDpracownika FROM [Nieobecnoœci pracowników] 
		WHERE DATEPART(yy, GETDATE()) = YEAR(DataZakoñczenia)
		)

GO
CREATE VIEW [Lista pracowników] AS
	SELECT LP1.IDosoby, LP1.Imiê, LP1.Nazwisko, LP1.Specjalizacja, LP2.[Liczba osób] FROM (
		SELECT O.IDosoby, O.Imiê, O.Nazwisko, P.Specjalizacja FROM Osoby O 
		JOIN Pracownicy P ON O.IDosoby = P.IDpracownika) LP1
	JOIN (SELECT P.Specjalizacja, COUNT(*) [Liczba osób] FROM Pracownicy P
		GROUP BY P.Specjalizacja) LP2
	ON LP1.Specjalizacja = LP2.Specjalizacja

GO
CREATE VIEW [Harmonogram pracowników] AS
	SELECT O1.IDosoby, O1.Nazwisko, O1.Imiê, ZP.[IDzespo³u podstawowego], H1.IDdy¿uru, 
	H1.DzieñTygodnia, H1.GodzinaRozpoczêcia, H1.GodzinaZakoñczenia FROM Osoby O1 
	JOIN Pracownicy P1 ON O1.IDosoby = P1.IDpracownika
	JOIN [Zespo³y podstawowe] ZP 
	ON (P1.IDpracownika = ZP.IDpracownika1 OR P1.IDpracownika = ZP.IDpracownika2 OR P1.IDpracownika = ZP.IDpracownika3)
	JOIN Harmonogram H1 ON (ZP.[IDzespo³u podstawowego] = H1.IDzespo³u1 OR ZP.[IDzespo³u podstawowego] = H1.IDzespo³u2)
	UNION
	SELECT O2.IDosoby, O2.Nazwisko, O2.Imiê, ZS.[IDzespo³u specjalnego], H2.IDdy¿uru, 
	H2.DzieñTygodnia, H2.GodzinaRozpoczêcia, H2.GodzinaZakoñczenia FROM Osoby O2 
	JOIN Pracownicy P2 ON O2.IDosoby = P2.IDpracownika
	JOIN [Zespo³y specjalne] ZS
	ON (P2.IDpracownika = ZS.IDpracownika1 OR P2.IDpracownika = ZS.IDpracownika2 OR 
	P2.IDpracownika = ZS.IDpracownika3 OR P2.IDpracownika = ZS.IDpracownika4)
	JOIN Harmonogram H2 ON (ZS.[IDzespo³u specjalnego] = H2.IDzespo³u1 OR ZS.[IDzespo³u specjalnego] = H2.IDzespo³u2)

GO
CREATE VIEW [Historia pacjenta] AS
	SELECT O.IDosoby, O.Nazwisko, O.Imiê, W.IDwezwania, UP.Diagnoza, UP.[Liczba kocy termicznych], UP.[Liczba opatrunków], 
	UP.[Liczba par rêkawiczek], UP.[Liczba resuscytatorów], UP.[Liczba stabilizatorów] FROM Osoby O
	JOIN Wezwania W ON O.IDosoby = W.IDpacjenta
	JOIN [Udzielana pomoc] UP ON W.IDwezwania = UP.IDwezwania

GO
CREATE VIEW [Suma kosztów - pacjenci] AS
	SELECT O.IDosoby, O.Nazwisko, O.Imiê, SUM(UP.[Poniesione koszty]) AS [Suma kosztów] FROM Osoby O 
	JOIN Wezwania W ON O.IDosoby = W.IDpacjenta
	JOIN [Udzielana pomoc] UP ON W.IDwezwania = UP.IDwezwania
	GROUP BY O.IDosoby, O.Nazwisko, O.Imiê

GO
CREATE VIEW [Niewykorzystany urlop] AS
	SELECT O.IDosoby, O.Nazwisko, O.Imiê, P.LiczbaDniUrlopu FROM Osoby O
	JOIN Pracownicy P ON O.IDosoby = P.IDpracownika


-------------------------------------------------------------


GO 
CREATE FUNCTION FN_Harmonogram_tygodniowy() RETURNS TABLE AS RETURN
	SELECT * FROM Harmonogram H1
	JOIN [Zespo³y ratownicze] ZR1 ON H1.IDzespo³u1 = ZR1.IDzespo³u
	UNION
	SELECT * FROM Harmonogram H2
	JOIN [Zespo³y ratownicze] ZR2 ON H2.IDzespo³u2 = ZR2.IDzespo³u

GO
CREATE FUNCTION FN_TOP_5_pracowników() RETURNS TABLE AS RETURN
	SELECT TOP 5 WITH TIES * FROM (
		SELECT O1.IDosoby, O1.Nazwisko, O1.Imiê, SUBTAB1.[Liczba wezwañ] FROM Osoby O1 
		JOIN(SELECT O2.IDosoby, COUNT(*) AS [Liczba wezwañ] FROM Osoby O2
			JOIN Pracownicy P1 ON O2.IDosoby = P1.IDpracownika
			JOIN [Zespo³y podstawowe] ZP ON (P1.IDpracownika = ZP.IDpracownika1 OR 
			P1.IDpracownika = ZP.IDpracownika2 OR P1.IDpracownika = ZP.IDpracownika3)
			JOIN Wezwania W1 ON ZP.[IDzespo³u podstawowego] = W1.IDzespo³u
			GROUP BY O2.IDosoby) AS SUBTAB1
		ON O1.IDosoby = SUBTAB1.IDosoby
		UNION
		SELECT O3.IDosoby, O3.Nazwisko, O3.Imiê, SUBTAB2.[Liczba wezwañ] FROM Osoby O3 
		JOIN(SELECT O3.IDosoby, COUNT(*) AS [Liczba wezwañ] FROM Osoby O3
			JOIN Pracownicy P2 ON O3.IDosoby = P2.IDpracownika
			JOIN [Zespo³y specjalne] ZS ON (P2.IDpracownika = ZS.IDpracownika1 OR 
			P2.IDpracownika = ZS.IDpracownika2 OR P2.IDpracownika = ZS.IDpracownika3
			OR P2.IDpracownika = ZS.IDpracownika4)
			JOIN Wezwania W2 ON ZS.[IDzespo³u specjalnego] = W2.IDzespo³u
			GROUP BY O3.IDosoby) AS SUBTAB2
		ON O3.IDosoby = SUBTAB2.IDosoby) AS SUBTAB
	ORDER BY SUBTAB.[Liczba wezwañ] DESC

GO
CREATE FUNCTION FN_Statystyki_zarobków() RETURNS TABLE AS RETURN
	SELECT MAX(WP.[Kwota wynagrodzenia]) AS [Max], MIN(WP.[Kwota wynagrodzenia]) AS [MIN], 
	AVG(WP.[Kwota wynagrodzenia]) AS Œrednia FROM Pracownicy P 
	JOIN [Wynagrodzenie pracowników] WP ON P.Specjalizacja = WP.Specjalizacja
	

-------------------------------------------------


GO
CREATE TRIGGER TR_Uaktualnij_dni_urlopu
ON [Nieobecnoœci pracowników] 
AFTER INSERT 
AS
	UPDATE Pracownicy SET LiczbaDniUrlopu=(LiczbaDniUrlopu-Datediff(day,(SELECT [Nieobecnoœci pracowników].DataRozpoczêcia FROM INSERTED,[Nieobecnoœci pracowników] 
	WHERE INSERTED.IDpracownika=[Nieobecnoœci pracowników].IDpracownika),(SELECT [Nieobecnoœci pracowników].DataZakoñczenia FROM INSERTED,[Nieobecnoœci pracowników] 
	WHERE INSERTED.IDpracownika=[Nieobecnoœci pracowników].IDpracownika)))
	FROM Pracownicy JOIN INSERTED ON Pracownicy.IDpracownika=INSERTED.IDpracownika

GO
CREATE TRIGGER TR_Data_wezwania
ON Wezwania 
AFTER INSERT
AS
	DECLARE @Miejscowosc NVARCHAR(50)
	SET @Miejscowosc=(SELECT [Miejsce wezwania] FROM INSERTED)
	PRINT 'Otrzymaliœmy nowe wezwanie do miejscowoœci '+ @Miejscowosc
	PRINT 'Aktualna data to: '
	PRINT GETDATE()

GO 
CREATE TRIGGER TR_Limit_urlopów
ON [Nieobecnoœci pracowników]
AFTER INSERT,UPDATE
AS
	DECLARE @Limit_url INT=3
	IF((SELECT PowódNieobecnoœci FROM INSERTED)='urlop')
	BEGIN
		IF(@Limit_url>(SELECT COUNT(IDpracownika) FROM [Nieobecnoœci pracowników]
			WHERE DataRozpoczêcia>=(SELECT DataRozpoczêcia FROM INSERTED) AND DataZakoñczenia<=(SELECT DataZakoñczenia FROM INSERTED)))
			PRINT 'Pomyœlnie dodano urlop'
		ELSE
		BEGIN
			DELETE N FROM [Nieobecnoœci pracowników] AS N INNER JOIN INSERTED I
			ON I.IDpracownika=N.IDpracownika AND I.PowódNieobecnoœci=N.PowódNieobecnoœci AND I.DataRozpoczêcia=N.DataRozpoczêcia AND I.DataZakoñczenia=N.DataZakoñczenia
			PRINT 'Nie mo¿na wzi¹æ urlopu'
		END
	END
	ELSE
	PRINT 'Dodano zwolnienie lekarskie'

GO 
CREATE TRIGGER TR_Aktualizacja_poniesione_koszta
ON [Udzielana pomoc]
AFTER INSERT
AS
	UPDATE [Udzielana pomoc] SET [Poniesione koszty]=((SELECT [Liczba opatrunków] FROM INSERTED)*(SELECT [Cena opatrunku] FROM INSERTED)
	+(SELECT [Liczba par rêkawiczek] FROM INSERTED)*(SELECT [Cena pary rêkawiczek] FROM INSERTED)
	+(SELECT [Liczba kocy termicznych] FROM INSERTED)*(SELECT [Cena koca termicznego] FROM INSERTED)
	+(SELECT [Liczba resuscytatorów] FROM INSERTED)*(SELECT [Cena resuscytatora] FROM INSERTED)
	+(SELECT [Liczba stabilizatorów] FROM INSERTED)*(SELECT [Cena stabilizatora] FROM INSERTED))
	FROM [Udzielana pomoc] JOIN INSERTED ON [Udzielana pomoc].IDwezwania=INSERTED.IDwezwania AND [Udzielana pomoc].Diagnoza=INSERTED.Diagnoza

GO
CREATE TRIGGER TR_Dy¿ury 
ON Harmonogram 
AFTER INSERT
AS
	IF((SELECT COUNT(IDzespo³u1) FROM INSERTED
		WHERE IDzespo³u1 IN(SELECT [IDzespo³u podstawowego] FROM [Zespo³y podstawowe]))>0 AND((SELECT COUNT(IDzespo³u2) FROM INSERTED
		WHERE IDzespo³u2 IN(SELECT [IDzespo³u podstawowego] FROM [Zespo³y podstawowe]))>0))
		BEGIN
			PRINT'le dobrane zespo³y'
			ROLLBACK
		END
	ELSE
		IF((SELECT COUNT(IDzespo³u1) FROM INSERTED
			WHERE IDzespo³u1 IN(SELECT [IDzespo³u specjalnego] FROM [Zespo³y specjalne]))>0 AND ((SELECT COUNT(IDzespo³u2) FROM INSERTED
			WHERE IDzespo³u2 IN(SELECT [IDzespo³u specjalnego] FROM [Zespo³y specjalne]))>0))
			BEGIN
				PRINT'le dobrane zespo³y'
				ROLLBACK
			END
		ELSE
			PRINT 'Zespo³y s¹ odpowiednie dla dy¿uru. Dodano zespó³ specjalny i podstawowy'

GO
CREATE PROC PR_Wezwania_z_wiêksz¹_cen¹_od_podanej(@cena INT)
AS
	SELECT W.IDwezwania,[Poniesione koszty], [Miejsce wezwania],[Powód wezwania] FROM Wezwania AS W
	JOIN [Udzielana pomoc] AS U ON W.IDwezwania=U.IDwezwania
	WHERE [Poniesione koszty]>@cena
	ORDER BY [Poniesione koszty] DESC

GO
CREATE PROC PR_Podzia³_p³ci
AS
	SELECT P³eæ as [P³eæ pacjenta], COUNT(*) as Liczba, CAST(100 * COUNT(*) / (SELECT COUNT(*) FROM Pacjenci) AS NVARCHAR) + '%' AS [Podzial procentowy] FROM Pacjenci
	JOIN Osoby ON Pacjenci.IDpacjenta = Osoby.IDosoby
	GROUP BY P³eæ
	SELECT P³eæ as [P³eæ pracownika], COUNT(*) as Liczba, CAST(100 * COUNT(*) / (SELECT COUNT(*) FROM Pracownicy) AS NVARCHAR) + '%' AS [Podzial procentowy] FROM Pracownicy
	JOIN Osoby ON Pracownicy.IDpracownika = Osoby.IDosoby
	GROUP BY P³eæ

GO
CREATE PROC PR_Podwy¿ka_zarobków(@Podwyzka INT)
AS
	UPDATE [Wynagrodzenie pracowników] SET [Kwota wynagrodzenia] =([Kwota wynagrodzenia]+[Kwota wynagrodzenia]*@Podwyzka*0.01)

GO
CREATE PROC PR_Przegl¹d_techniczny(@liczba_dni INT)
AS
	SELECT IDkaretki,Nr_rejestracyjny,[Data produkcji] [Data przegl¹du technicznego] FROM Karetki AS K
	INNER JOIN [Dane przegl¹du technicznego] AS D ON D.[IDgrupy marki karetki]=K.[IDgrupy marki karetki]
	WHERE @liczba_dni> DATEDIFF(day,[Data przegl¹du technicznego],GETDATE())

GO
CREATE PROC PR_Czy_pacjent_ubezpieczony(@Podaj_pesel INT, @result VARCHAR(3) OUTPUT)
AS
	SET @result=(SELECT Ubezpieczenie from Pacjenci
	WHERE @Podaj_pesel=PESEL )
GO

USE master

