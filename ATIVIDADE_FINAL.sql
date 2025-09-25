--1
SELECT O.ShipCity,
ISNULL ( O.ShipRegion, 'N/A') AS REGIAO,
O.ShipCountry AS PAIS,
ROUND(SUM((OD.Quantity * OD.UnitPrice) * (1 - OD.Discount)),2) AS TOTAL_VENDA
FROM Orders O 
INNER JOIN [Order Details] OD ON OD.OrderID =  O.OrderID
GROUP BY ISNULL ( O.ShipRegion, 'N/A'),
O.ShipCountry,
O.ShipCity
ORDER BY TOTAL_VENDA DESC

SELECT * FROM Orders

--2
SELECT TOP 10 FO.CompanyName AS FORNECEDOR,
SUM(PROD.UnitsInStock * PROD.UnitPrice) AS ITENS_ESTOQUE
FROM Products PROD
INNER JOIN Suppliers FO ON FO.SupplierID = PROD.SupplierID
GROUP BY 
 FO.CompanyName
ORDER BY ITENS_ESTOQUE DESC

--3
SELECT PROD.ProductName AS NOME_PRODUTO,
         SUM(OD.Quantity * OD.UnitPrice) AS QTD_VENDIDA,
                           O.ShipCountry AS NOME_PAIS,
                             O.OrderDate AS DATA_VENDA,
                       PROD.Discontinued AS DESCONTINUADOS
FROM Products PROD
INNER JOIN [Order Details] OD ON OD.ProductID = PROD.ProductID
INNER JOIN Orders O ON O.OrderID = OD.OrderID
WHERE PROD.Discontinued != 0
GROUP BY PROD.ProductName,
    O.ShipCountry,
    O.OrderDate,
    PROD.Discontinued
ORDER BY DATA_VENDA DESC


--4
-- TRAZER QUAIS PRODUTOS  VENDERAM MAIS POR CATEGORIA
-- CATEGORIA MAIS VENDIDAS

SELECT * 
FROM (
 SELECT CAT.CategoryName AS CATEGORIA,
 PROD.ProductName AS PRODUTOS,
  ROUND(SUM((OD.Quantity * OD.UnitPrice) * (1 - OD.Discount)),2) AS MAIS_VENDIDO_POR_CATEGORIA,
  ROW_NUMBER()OVER (PARTITION BY CAT.CategoryName ORDER BY
  ROUND(SUM((OD.Quantity * OD.UnitPrice) * (1 - OD.Discount)),2) DESC) AS PODIO
 FROM Products PROD
 INNER JOIN Categories CAT ON CAT.CategoryID = PROD.CategoryID
 INNER JOIN [Order Details] OD ON OD.ProductID = PROD.ProductID
 GROUP BY 
    CAT.CategoryName,
    PROD.ProductName
)AS PRODUTOS_MAIS_VENDIDOS 
WHERE 
   PODIO = 1
ORDER BY 
   MAIS_VENDIDO_POR_CATEGORIA DESC

--MEDIA DE FRENTE POR CIDADE, 

SELECT TRANS.CompanyName AS NOME_TRANSPORTADORA,
AVG(O.Freight) AS MEDIA_FRETE,
O.ShipCity AS CIDADE
FROM Orders O
INNER JOIN Shippers TRANS ON TRANS.ShipperID =  O.ShipVia
GROUP BY TRANS.CompanyName, 
O.ShipCity
ORDER BY MEDIA_FRETE DESC

--CORREÇÃO DO PROFESSOR OUTROS CODIGOS DOS AMIGOS
--1 – Crie uma consulta que mostre um ranking das cidades que mais compraram da empresa em nível de faturamento.
--Trazer as seguintes colunas: Nome da cidade, estado, nome do país e total faturado
--Ex:  São José do Rio Preto | SP | Brazil  | 100000
--       Curitiba            | PR | Brazil | 152000

SELECT O.ShipCity AS CIDADE, ISNULL(O.ShipRegion, 'N/A') AS REGIAO, O.ShipCountry AS PAIS ,
	   ROUND(SUM((OD.Quantity * OD.UnitPrice) * (1 - OD.Discount)), 2) AS FATURAMENTO
FROM Orders O
INNER JOIN [Order Details] OD ON OD.OrderID = O.OrderID
GROUP BY O.ShipCity, O.ShipRegion, O.ShipCountry
ORDER BY FATURAMENTO DESC

--2 – Crie uma consulta que mostre os 10 fornecedores que mais possuem itens em estoque na empresa 
-- (em nível financeiro):
--Ex:   Fornecedor 1 | 30000
--      Fornecedor 2 | 12000

SELECT TOP 10 S.CompanyName AS FORNECEDOR, SUM(P.UnitPrice * P.UnitsInStock) AS VLR_FINANCEIRO
FROM Suppliers S
INNER JOIN Products P ON P.SupplierID = S.SupplierID
GROUP BY S.CompanyName
ORDER BY VLR_FINANCEIRO DESC

--3 – Crie uma consulta que mostre para quais países os produtos descontinuados já foram vendidos.
--Trazer o nome do produto, a quantidade vendida, o nome do país e a data da venda (esta consulta terá 
--várias linhas...).

SELECT P.ProductName AS PRODUTO, OD.Quantity AS QTD, O.ShipCountry AS PAIS, 
	   O.OrderDate AS DATA_VENDA
FROM Products P
INNER JOIN [Order Details] OD ON OD.ProductID = P.ProductID
INNER JOIN Orders O           ON O.OrderID = OD.OrderID
WHERE P.Discontinued = 1
ORDER BY DATA_VENDA

--4 - Se coloque na posição de um gestor e crie 2 consultas que você acredita ser importantes para
--analisar os dados da empresa.
--Temos informações de: Clientes, fornecedores, vendedores, produtos,
--categorias, transportadoras, países, cidades... Use sua criatividade e gere alguns insights!

-- CONSULTA DO VITOR:
-- DIFERENÇA ENTRE DATA DE ENVIO E DATA DE ENTREGA PREVISTA
SELECT O.OrderID AS PEDIDO, PD.ProductName ,DATEDIFF(DAY, O.OrderDate,O.RequiredDate) AS PZ_PREVISTO,
DATEDIFF(DAY, O.OrderDate,O.ShippedDate) AS PZ_ENTREGA, SP.Country AS PAIS_ORIGEM,
O.ShipCountry AS PAIS_DESTINO
FROM Orders O
INNER JOIN [Order Details] OD ON OD.OrderID = O.OrderID
INNER JOIN Products PD ON PD.ProductID = OD.ProductID
INNER JOIN Suppliers SP ON SP.SupplierID = PD.SupplierID
WHERE DATEDIFF(DAY, O.OrderDate,O.ShippedDate) >= DATEDIFF(DAY, O.OrderDate,O.RequiredDate)
ORDER BY PZ_ENTREGA DESC, PZ_PREVISTO DESC, PD.ProductName 

/* A TABELA DEMONSTRA O PAIS DE DESTINO QUE MAIOR ATRASO NAS ENTREGAS
*/
SELECT PD.ProductName AS PRODUTO,DATEDIFF(DAY, O.OrderDate,O.RequiredDate) AS PZ_PREVISTO,
DATEDIFF(DAY, O.OrderDate,O.ShippedDate) AS PZ_ENTREGA, SP.Country AS PAIS_ORIGEM,
O.ShipCountry AS PAIS_DESTINO, DATEDIFF(DAY, O.OrderDate,O.ShippedDate) - DATEDIFF(DAY, O.OrderDate,O.RequiredDate) AS DIF_DATA
FROM Orders O
INNER JOIN [Order Details] OD ON OD.OrderID = O.OrderID
INNER JOIN Products PD ON PD.ProductID = OD.ProductID
INNER JOIN Suppliers SP ON SP.SupplierID = PD.SupplierID
WHERE DATEDIFF(DAY, O.OrderDate,O.ShippedDate) >= DATEDIFF(DAY, O.OrderDate,O.RequiredDate)
ORDER BY DIF_DATA DESC, PAIS_DESTINO

--- CONSULTA ABAIXO DO RAFAEL ALMEIDA

--- CONSULTA TRAZENDO O TOP 1 DE PRODUTOS EM FATURAMENTO POR PAÍS

WITH TOP_1 AS
(
SELECT
	O.ShipCountry AS 'PAÍS',
	ROUND(SUM((OD.Quantity * OD.UnitPrice) * (1 - OD.Discount)),2) AS 'TOTAL_VENDA',
	ROW_NUMBER() OVER (PARTITION BY O.ShipCountry ORDER BY
	ROUND(SUM((OD.Quantity * OD.UnitPrice) * (1 - OD.Discount)),2) DESC) AS 'RANKING',
	P.ProductName AS 'PRODUTO'
FROM
	Orders O
	INNER JOIN [Order Details] OD ON OD.OrderID = O.OrderID
	INNER JOIN Products P ON  P.ProductID = OD.ProductID
	INNER JOIN Categories C ON C.CategoryID = P.CategoryID
GROUP BY
	O.ShipCountry,
	P.ProductName
)
SELECT
	T.PAÍS,
	T.PRODUTO,
	T.TOTAL_VENDA
FROM 
	TOP_1 T
WHERE
	RANKING = 1
ORDER BY
	TOTAL_VENDA DESC

-- CONSULTA DO MATHEUS MORTARI
-- TRAZER QUAIS PRODUTOS  VENDERAM MAIS POR CATEGORIA
-- CATEGORIA MAIS VENDIDAS

SELECT * 
FROM (
 SELECT CAT.CategoryName AS CATEGORIA,
 PROD.ProductName AS PRODUTOS,
  ROUND(SUM((OD.Quantity * OD.UnitPrice) * (1 - OD.Discount)),2) AS MAIS_VENDIDO_POR_CATEGORIA,
  ROW_NUMBER()OVER (PARTITION BY CAT.CategoryName ORDER BY
  ROUND(SUM((OD.Quantity * OD.UnitPrice) * (1 - OD.Discount)),2) DESC) AS PODIO
 FROM Products PROD
 INNER JOIN Categories CAT ON CAT.CategoryID = PROD.CategoryID
 INNER JOIN [Order Details] OD ON OD.ProductID = PROD.ProductID
 GROUP BY 
    CAT.CategoryName,
    PROD.ProductName
)AS PRODUTOS_MAIS_VENDIDOS 
WHERE 
   PODIO = 1
ORDER BY 
   MAIS_VENDIDO_POR_CATEGORIA DESC

-- CONSULTA DO ÉDER MARQUES

-- Q4.2 CATEGORIA MAIS VENDIDA POR PAIS
WITH RANKING AS (
	SELECT O.ShipCountry AS PAIS, C.CategoryName AS CATEGORIA, 
		SUM(OD.Quantity) AS QTD_VENDIDA,
		ROW_NUMBER() OVER (PARTITION BY O.ShipCountry ORDER BY 
			SUM(OD.Quantity) DESC) AS RANKING
	FROM Categories C
		INNER JOIN Products P         ON P.CategoryID = C.CategoryID
		INNER JOIN [Order Details] OD ON OD.ProductID = P.ProductID
		INNER JOIN Orders O           ON O.OrderID = OD.OrderID
	GROUP BY O.ShipCountry, C.CategoryName
)
SELECT R.PAIS, R.CATEGORIA, R.QTD_VENDIDA
FROM RANKING R
WHERE R.RANKING IN (1,2,3)
ORDER BY PAIS


-- Q4.3 QUANTIDADE DE PAISES EM QUE A CATEGORIA FOI MAIS VENDIDA
WITH RANKING AS (
	SELECT O.ShipCountry AS PAIS, C.CategoryName AS CATEGORIA, 
		SUM(OD.Quantity) AS QTD_VENDIDA,
		ROW_NUMBER() OVER (PARTITION BY O.ShipCountry ORDER BY 
			SUM(OD.Quantity) DESC) AS RANKING
	FROM Categories C
		INNER JOIN Products P         ON P.CategoryID = C.CategoryID
		INNER JOIN [Order Details] OD ON OD.ProductID = P.ProductID
		INNER JOIN Orders O           ON O.OrderID = OD.OrderID
	GROUP BY C.CategoryName, O.ShipCountry
)
SELECT R.CATEGORIA, 
	SUM(R.RANKING) AS QTD_PAIS_CATEGORIA_MAIS_VENDIDA 
FROM RANKING R
WHERE R.RANKING = 1
GROUP BY R.CATEGORIA
ORDER BY QTD_PAIS_CATEGORIA_MAIS_VENDIDA  DESC