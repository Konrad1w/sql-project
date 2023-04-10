DROP DATABASE [Pogotowie ratunkowe]
GO

CREATE DATABASE [Pogotowie ratunkowe]
GO

USE [Pogotowie ratunkowe]
GO


---------------------------------------------------


CREATE TABLE Osoby(
	IDosoby INT IDENTITY(1,1) PRIMARY KEY,
	Imi� NVARCHAR(50) NOT NULL,
	Nazwisko NVARCHAR(50) NOT NULL,
	[Data urodzenia] DATE NOT NULL,
	[Adres zamieszkania] NVARCHAR(50) NOT NULL,
	Narodowo�� NVARCHAR(50),
	P�e� NVARCHAR(1) NOT NULL,
	CHECK(P�e� IN('M','K'))
)

CREATE TABLE Pracownicy (
	IDpracownika INT REFERENCES Osoby(IDosoby) PRIMARY KEY,
	DataZatrudnienia DATE NOT NULL,
	Specjalizacja NVARCHAR(50) NOT NULL,
	LiczbaDniUrlopu INT -- dni pozosta�e do wykorzystania
	CHECK(LiczbaDniUrlopu > 0) 
)

CREATE TABLE Pacjenci(
	IDpacjenta INT REFERENCES Osoby(IDosoby) PRIMARY KEY,
	PESEL INT UNIQUE NOT NULL,
	Ubezpieczenie NVARCHAR(3) NOT NULL,
	CHECK(Ubezpieczenie IN('TAK','NIE'))
)

CREATE TABLE [Dane przegl�du technicznego](
	[IDgrupy marki karetki] INT PRIMARY KEY,
	[Data produkcji] DATE NOT NULL,
	[Data zakupu] DATE NOT NULL
)
 
CREATE TABLE Karetki(
	IDkaretki INT PRIMARY KEY,
	[IDgrupy marki karetki] INT FOREIGN KEY REFERENCES [Dane przegl�du technicznego]([IDgrupy marki karetki])
	ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
	Dost�pno�� NVARCHAR(3),
	CHECK(Dost�pno�� IN('TAK','NIE')),
	Nr_rejestracyjny NVARCHAR(10) UNIQUE NOT NULL,
	[Data przegl�du technicznego] DATE NOT NULL
)

CREATE TABLE [Zespo�y ratownicze] (
	IDzespo�u INT PRIMARY KEY,
	RodzajZespo�u NVARCHAR(20) NOT NULL CHECK(RodzajZespo�u IN ('podstawowy', 'specjalny')),
	IDkaretki INT FOREIGN KEY REFERENCES Karetki(IDkaretki) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
	LiczbaDniPracy INT NOT NULL -- tygodniowo
)

CREATE TABLE [Zespo�y podstawowe] (
	[IDzespo�u podstawowego] INT PRIMARY KEY,
	IDpracownika1 INT NOT NULL,
	IDpracownika2 INT NOT NULL,
	IDpracownika3 INT NOT NULL
	FOREIGN KEY ([IDzespo�u podstawowego]) REFERENCES [Zespo�y ratownicze] (IDzespo�u) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (IDpracownika1) REFERENCES Pracownicy (IDpracownika),
	FOREIGN KEY (IDpracownika2) REFERENCES Pracownicy (IDpracownika),
	FOREIGN KEY (IDpracownika3) REFERENCES Pracownicy (IDpracownika) 
)

CREATE TABLE [Zespo�y specjalne] (
	[IDzespo�u specjalnego] INT PRIMARY KEY,
	IDpracownika1 INT NOT NULL,
	IDpracownika2 INT NOT NULL,
	IDpracownika3 INT NOT NULL,
	IDpracownika4 INT NOT NULL,
	FOREIGN KEY ([IDzespo�u specjalnego]) REFERENCES [Zespo�y ratownicze] (IDzespo�u) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (IDpracownika1) REFERENCES Pracownicy (IDpracownika),
	FOREIGN KEY (IDpracownika2) REFERENCES Pracownicy (IDpracownika),
	FOREIGN KEY (IDpracownika3) REFERENCES Pracownicy (IDpracownika), 
	FOREIGN KEY (IDpracownika4) REFERENCES Pracownicy (IDpracownika) 
)

CREATE TABLE [Nieobecno�ci pracownik�w] (
	IDpracownika INT,
	Pow�dNieobecno�ci NVARCHAR(20) NOT NULL CHECK(Pow�dNieobecno�ci IN ('urlop', '[zwolnienie lekarskie]')),
	DataRozpocz�cia DATE,
	DataZako�czenia DATE NOT NULL
	PRIMARY KEY (IDpracownika, DataRozpocz�cia),
	FOREIGN KEY (IDpracownika) REFERENCES Pracownicy (IDpracownika) ON DELETE CASCADE ON UPDATE CASCADE
)

CREATE TABLE Urlopy (
	IDpracownika INT,
	DataRozpocz�cia DATE,
	TypUrlopu NVARCHAR(20) NOT NULL CHECK(TypUrlopu IN ('p�atny', 'bezp�atny'))
	PRIMARY KEY (IDpracownika, DataRozpocz�cia),
	FOREIGN KEY (IDpracownika, DataRozpocz�cia)
	REFERENCES [Nieobecno�ci pracownik�w] (IDpracownika, DataRozpocz�cia) 
	ON DELETE CASCADE ON UPDATE CASCADE
)

CREATE TABLE [Zwolnienia lekarskie] (
	IDpracownika INT,
	DataRozpocz�cia DATE,
	NrZwolnieniaLekarskieGO INT NOT NULL
	PRIMARY KEY (IDpracownika, DataRozpocz�cia),
	FOREIGN KEY (IDpracownika, DataRozpocz�cia)
	REFERENCES [Nieobecno�ci pracownik�w] (IDpracownika, DataRozpocz�cia) 
	ON DELETE CASCADE ON UPDATE CASCADE
)

CREATE TABLE Harmonogram (
	IDdy�uru INT PRIMARY KEY,
	Dzie�Tygodnia NVARCHAR(15),
	GodzinaRozpocz�cia TIME,
	GodzinaZako�czenia TIME,
	CHECK(GodzinaRozpocz�cia < GodzinaZako�czenia),
	IDzespo�u1 INT FOREIGN KEY REFERENCES [Zespo�y ratownicze] (IDzespo�u) NOT NULL,
	IDzespo�u2 INT FOREIGN KEY REFERENCES [Zespo�y ratownicze] (IDzespo�u) NOT NULL
	UNIQUE (IDdy�uru, Dzie�Tygodnia)
)

CREATE TABLE [Wynagrodzenie pracownik�w](
	Specjalizacja NVARCHAR(50) PRIMARY KEY,
	[Kwota wynagrodzenia] MONEY NOT NULL
)

CREATE TABLE Wezwania(
	IDwezwania INT PRIMARY KEY,
	IDpacjenta INT FOREIGN KEY REFERENCES Pacjenci(IDpacjenta) ON UPDATE CASCADE ON DELETE CASCADE UNIQUE NOT NULL,
	IDzespo�u INT FOREIGN KEY REFERENCES [Zespo�y ratownicze](IDzespo�u) NOT NULL,
	Nr_telefonu NVARCHAR(9) NOT NULL,
	CHECK (Nr_telefonu NOT LIKE '%[^0-9]%'),
	[Miejsce wezwania] NVARCHAR(50) NOT NULL,
	[Pow�d wezwania] NVARCHAR(50)
)

CREATE TABLE [Udzielana pomoc](
	IDwezwania INT FOREIGN KEY REFERENCES Wezwania(IDwezwania) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
	Diagnoza NVARCHAR(50) NOT NULL,
	[Liczba opatrunk�w] INT NOT NULL,
	[Cena opatrunku] MONEY NOT NULL,
	[Liczba par r�kawiczek] INT NOT NULL,
	[Cena pary r�kawiczek] MONEY NOT NULL,
	[Liczba kocy termicznych] INT NOT NULL,
	[Cena koca termicznego] MONEY NOT NULL,
	[Liczba resuscytator�w] INT NOT NULL,
	[Cena resuscytatora] MONEY NOT NULL,
	[Liczba stabilizator�w] INT NOT NULL,
	[Cena stabilizatora] MONEY NOT NULL,
	[Poniesione koszty] MONEY NOT NULL
)

CREATE TABLE Cennik(
	[Cena opatrunku] MONEY NOT NULL,
	[Cena pary r�kawiczek] MONEY NOT NULL,
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
CREATE VIEW [Brak nieobecno�ci] AS
	SELECT * FROM Osoby O JOIN Pracownicy P ON O.IDosoby = P.IDpracownika
	WHERE O.IDosoby NOT IN (
		SELECT IDpracownika FROM [Nieobecno�ci pracownik�w] 
		WHERE DATEPART(yy, GETDATE()) = YEAR(DataZako�czenia)
		)

GO
CREATE VIEW [Lista pracownik�w] AS
	SELECT LP1.IDosoby, LP1.Imi�, LP1.Nazwisko, LP1.Specjalizacja, LP2.[Liczba os�b] FROM (
		SELECT O.IDosoby, O.Imi�, O.Nazwisko, P.Specjalizacja FROM Osoby O 
		JOIN Pracownicy P ON O.IDosoby = P.IDpracownika) LP1
	JOIN (SELECT P.Specjalizacja, COUNT(*) [Liczba os�b] FROM Pracownicy P
		GROUP BY P.Specjalizacja) LP2
	ON LP1.Specjalizacja = LP2.Specjalizacja

GO
CREATE VIEW [Harmonogram pracownik�w] AS
	SELECT O1.IDosoby, O1.Nazwisko, O1.Imi�, ZP.[IDzespo�u podstawowego], H1.IDdy�uru, 
	H1.Dzie�Tygodnia, H1.GodzinaRozpocz�cia, H1.GodzinaZako�czenia FROM Osoby O1 
	JOIN Pracownicy P1 ON O1.IDosoby = P1.IDpracownika
	JOIN [Zespo�y podstawowe] ZP 
	ON (P1.IDpracownika = ZP.IDpracownika1 OR P1.IDpracownika = ZP.IDpracownika2 OR P1.IDpracownika = ZP.IDpracownika3)
	JOIN Harmonogram H1 ON (ZP.[IDzespo�u podstawowego] = H1.IDzespo�u1 OR ZP.[IDzespo�u podstawowego] = H1.IDzespo�u2)
	UNION
	SELECT O2.IDosoby, O2.Nazwisko, O2.Imi�, ZS.[IDzespo�u specjalnego], H2.IDdy�uru, 
	H2.Dzie�Tygodnia, H2.GodzinaRozpocz�cia, H2.GodzinaZako�czenia FROM Osoby O2 
	JOIN Pracownicy P2 ON O2.IDosoby = P2.IDpracownika
	JOIN [Zespo�y specjalne] ZS
	ON (P2.IDpracownika = ZS.IDpracownika1 OR P2.IDpracownika = ZS.IDpracownika2 OR 
	P2.IDpracownika = ZS.IDpracownika3 OR P2.IDpracownika = ZS.IDpracownika4)
	JOIN Harmonogram H2 ON (ZS.[IDzespo�u specjalnego] = H2.IDzespo�u1 OR ZS.[IDzespo�u specjalnego] = H2.IDzespo�u2)

GO
CREATE VIEW [Historia pacjenta] AS
	SELECT O.IDosoby, O.Nazwisko, O.Imi�, W.IDwezwania, UP.Diagnoza, UP.[Liczba kocy termicznych], UP.[Liczba opatrunk�w], 
	UP.[Liczba par r�kawiczek], UP.[Liczba resuscytator�w], UP.[Liczba stabilizator�w] FROM Osoby O
	JOIN Wezwania W ON O.IDosoby = W.IDpacjenta
	JOIN [Udzielana pomoc] UP ON W.IDwezwania = UP.IDwezwania

GO
CREATE VIEW [Suma koszt�w - pacjenci] AS
	SELECT O.IDosoby, O.Nazwisko, O.Imi�, SUM(UP.[Poniesione koszty]) AS [Suma koszt�w] FROM Osoby O 
	JOIN Wezwania W ON O.IDosoby = W.IDpacjenta
	JOIN [Udzielana pomoc] UP ON W.IDwezwania = UP.IDwezwania
	GROUP BY O.IDosoby, O.Nazwisko, O.Imi�

GO
CREATE VIEW [Niewykorzystany urlop] AS
	SELECT O.IDosoby, O.Nazwisko, O.Imi�, P.LiczbaDniUrlopu FROM Osoby O
	JOIN Pracownicy P ON O.IDosoby = P.IDpracownika


-------------------------------------------------------------


GO 
CREATE FUNCTION FN_Harmonogram_tygodniowy() RETURNS TABLE AS RETURN
	SELECT * FROM Harmonogram H1
	JOIN [Zespo�y ratownicze] ZR1 ON H1.IDzespo�u1 = ZR1.IDzespo�u
	UNION
	SELECT * FROM Harmonogram H2
	JOIN [Zespo�y ratownicze] ZR2 ON H2.IDzespo�u2 = ZR2.IDzespo�u

GO
CREATE FUNCTION FN_TOP_5_pracownik�w() RETURNS TABLE AS RETURN
	SELECT TOP 5 WITH TIES * FROM (
		SELECT O1.IDosoby, O1.Nazwisko, O1.Imi�, SUBTAB1.[Liczba wezwa�] FROM Osoby O1 
		JOIN(SELECT O2.IDosoby, COUNT(*) AS [Liczba wezwa�] FROM Osoby O2
			JOIN Pracownicy P1 ON O2.IDosoby = P1.IDpracownika
			JOIN [Zespo�y podstawowe] ZP ON (P1.IDpracownika = ZP.IDpracownika1 OR 
			P1.IDpracownika = ZP.IDpracownika2 OR P1.IDpracownika = ZP.IDpracownika3)
			JOIN Wezwania W1 ON ZP.[IDzespo�u podstawowego] = W1.IDzespo�u
			GROUP BY O2.IDosoby) AS SUBTAB1
		ON O1.IDosoby = SUBTAB1.IDosoby
		UNION
		SELECT O3.IDosoby, O3.Nazwisko, O3.Imi�, SUBTAB2.[Liczba wezwa�] FROM Osoby O3 
		JOIN(SELECT O3.IDosoby, COUNT(*) AS [Liczba wezwa�] FROM Osoby O3
			JOIN Pracownicy P2 ON O3.IDosoby = P2.IDpracownika
			JOIN [Zespo�y specjalne] ZS ON (P2.IDpracownika = ZS.IDpracownika1 OR 
			P2.IDpracownika = ZS.IDpracownika2 OR P2.IDpracownika = ZS.IDpracownika3
			OR P2.IDpracownika = ZS.IDpracownika4)
			JOIN Wezwania W2 ON ZS.[IDzespo�u specjalnego] = W2.IDzespo�u
			GROUP BY O3.IDosoby) AS SUBTAB2
		ON O3.IDosoby = SUBTAB2.IDosoby) AS SUBTAB
	ORDER BY SUBTAB.[Liczba wezwa�] DESC

GO
CREATE FUNCTION FN_Statystyki_zarobk�w() RETURNS TABLE AS RETURN
	SELECT MAX(WP.[Kwota wynagrodzenia]) AS [Max], MIN(WP.[Kwota wynagrodzenia]) AS [MIN], 
	AVG(WP.[Kwota wynagrodzenia]) AS �rednia FROM Pracownicy P 
	JOIN [Wynagrodzenie pracownik�w] WP ON P.Specjalizacja = WP.Specjalizacja
	

-------------------------------------------------


GO
CREATE TRIGGER TR_Uaktualnij_dni_urlopu
ON [Nieobecno�ci pracownik�w] 
AFTER INSERT 
AS
	UPDATE Pracownicy SET LiczbaDniUrlopu=(LiczbaDniUrlopu-Datediff(day,(SELECT [Nieobecno�ci pracownik�w].DataRozpocz�cia FROM INSERTED,[Nieobecno�ci pracownik�w] 
	WHERE INSERTED.IDpracownika=[Nieobecno�ci pracownik�w].IDpracownika),(SELECT [Nieobecno�ci pracownik�w].DataZako�czenia FROM INSERTED,[Nieobecno�ci pracownik�w] 
	WHERE INSERTED.IDpracownika=[Nieobecno�ci pracownik�w].IDpracownika)))
	FROM Pracownicy JOIN INSERTED ON Pracownicy.IDpracownika=INSERTED.IDpracownika

GO
CREATE TRIGGER TR_Data_wezwania
ON Wezwania 
AFTER INSERT
AS
	DECLARE @Miejscowosc NVARCHAR(50)
	SET @Miejscowosc=(SELECT [Miejsce wezwania] FROM INSERTED)
	PRINT 'Otrzymali�my nowe wezwanie do miejscowo�ci '+ @Miejscowosc
	PRINT 'Aktualna data to: '
	PRINT GETDATE()

GO 
CREATE TRIGGER TR_Limit_urlop�w
ON [Nieobecno�ci pracownik�w]
AFTER INSERT,UPDATE
AS
	DECLARE @Limit_url INT=3
	IF((SELECT Pow�dNieobecno�ci FROM INSERTED)='urlop')
	BEGIN
		IF(@Limit_url>(SELECT COUNT(IDpracownika) FROM [Nieobecno�ci pracownik�w]
			WHERE DataRozpocz�cia>=(SELECT DataRozpocz�cia FROM INSERTED) AND DataZako�czenia<=(SELECT DataZako�czenia FROM INSERTED)))
			PRINT 'Pomy�lnie dodano urlop'
		ELSE
		BEGIN
			DELETE N FROM [Nieobecno�ci pracownik�w] AS N INNER JOIN INSERTED I
			ON I.IDpracownika=N.IDpracownika AND I.Pow�dNieobecno�ci=N.Pow�dNieobecno�ci AND I.DataRozpocz�cia=N.DataRozpocz�cia AND I.DataZako�czenia=N.DataZako�czenia
			PRINT 'Nie mo�na wzi�� urlopu'
		END
	END
	ELSE
	PRINT 'Dodano zwolnienie lekarskie'

GO 
CREATE TRIGGER TR_Aktualizacja_poniesione_koszta
ON [Udzielana pomoc]
AFTER INSERT
AS
	UPDATE [Udzielana pomoc] SET [Poniesione koszty]=((SELECT [Liczba opatrunk�w] FROM INSERTED)*(SELECT [Cena opatrunku] FROM INSERTED)
	+(SELECT [Liczba par r�kawiczek] FROM INSERTED)*(SELECT [Cena pary r�kawiczek] FROM INSERTED)
	+(SELECT [Liczba kocy termicznych] FROM INSERTED)*(SELECT [Cena koca termicznego] FROM INSERTED)
	+(SELECT [Liczba resuscytator�w] FROM INSERTED)*(SELECT [Cena resuscytatora] FROM INSERTED)
	+(SELECT [Liczba stabilizator�w] FROM INSERTED)*(SELECT [Cena stabilizatora] FROM INSERTED))
	FROM [Udzielana pomoc] JOIN INSERTED ON [Udzielana pomoc].IDwezwania=INSERTED.IDwezwania AND [Udzielana pomoc].Diagnoza=INSERTED.Diagnoza

GO
CREATE TRIGGER TR_Dy�ury 
ON Harmonogram 
AFTER INSERT
AS
	IF((SELECT COUNT(IDzespo�u1) FROM INSERTED
		WHERE IDzespo�u1 IN(SELECT [IDzespo�u podstawowego] FROM [Zespo�y podstawowe]))>0 AND((SELECT COUNT(IDzespo�u2) FROM INSERTED
		WHERE IDzespo�u2 IN(SELECT [IDzespo�u podstawowego] FROM [Zespo�y podstawowe]))>0))
		BEGIN
			PRINT'�le dobrane zespo�y'
			ROLLBACK
		END
	ELSE
		IF((SELECT COUNT(IDzespo�u1) FROM INSERTED
			WHERE IDzespo�u1 IN(SELECT [IDzespo�u specjalnego] FROM [Zespo�y specjalne]))>0 AND ((SELECT COUNT(IDzespo�u2) FROM INSERTED
			WHERE IDzespo�u2 IN(SELECT [IDzespo�u specjalnego] FROM [Zespo�y specjalne]))>0))
			BEGIN
				PRINT'�le dobrane zespo�y'
				ROLLBACK
			END
		ELSE
			PRINT 'Zespo�y s� odpowiednie dla dy�uru. Dodano zesp� specjalny i podstawowy'

GO
CREATE PROC PR_Wezwania_z_wi�ksz�_cen�_od_podanej(@cena INT)
AS
	SELECT W.IDwezwania,[Poniesione koszty], [Miejsce wezwania],[Pow�d wezwania] FROM Wezwania AS W
	JOIN [Udzielana pomoc] AS U ON W.IDwezwania=U.IDwezwania
	WHERE [Poniesione koszty]>@cena
	ORDER BY [Poniesione koszty] DESC

GO
CREATE PROC PR_Podzia�_p�ci
AS
	SELECT P�e� as [P�e� pacjenta], COUNT(*) as Liczba, CAST(100 * COUNT(*) / (SELECT COUNT(*) FROM Pacjenci) AS NVARCHAR) + '%' AS [Podzial procentowy] FROM Pacjenci
	JOIN Osoby ON Pacjenci.IDpacjenta = Osoby.IDosoby
	GROUP BY P�e�
	SELECT P�e� as [P�e� pracownika], COUNT(*) as Liczba, CAST(100 * COUNT(*) / (SELECT COUNT(*) FROM Pracownicy) AS NVARCHAR) + '%' AS [Podzial procentowy] FROM Pracownicy
	JOIN Osoby ON Pracownicy.IDpracownika = Osoby.IDosoby
	GROUP BY P�e�

GO
CREATE PROC PR_Podwy�ka_zarobk�w(@Podwyzka INT)
AS
	UPDATE [Wynagrodzenie pracownik�w] SET [Kwota wynagrodzenia] =([Kwota wynagrodzenia]+[Kwota wynagrodzenia]*@Podwyzka*0.01)

GO
CREATE PROC PR_Przegl�d_techniczny(@liczba_dni INT)
AS
	SELECT IDkaretki,Nr_rejestracyjny,[Data produkcji] [Data przegl�du technicznego] FROM Karetki AS K
	INNER JOIN [Dane przegl�du technicznego] AS D ON D.[IDgrupy marki karetki]=K.[IDgrupy marki karetki]
	WHERE @liczba_dni> DATEDIFF(day,[Data przegl�du technicznego],GETDATE())

GO
CREATE PROC PR_Czy_pacjent_ubezpieczony(@Podaj_pesel INT, @result VARCHAR(3) OUTPUT)
AS
	SET @result=(SELECT Ubezpieczenie from Pacjenci
	WHERE @Podaj_pesel=PESEL )
GO

USE master

