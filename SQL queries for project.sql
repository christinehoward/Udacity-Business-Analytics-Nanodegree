/* Query 1 */

SELECT
  G.Name "Genre",
  SUM(IL.Quantity* IL.UnitPrice) AS "Total Amount USD"
FROM Genre G
JOIN Track T
  ON G.GenreId = T.GenreId
JOIN InvoiceLine IL
  ON T.TrackId = IL.TrackId
JOIN Invoice I
  ON I.InvoiceId = IL.InvoiceId
WHERE STRFTIME('%Y', I.InvoiceDate) = '2012'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5 ;


/* Query 2 */

SELECT
  Art.ArtistId Artist,
  CASE
    WHEN COUNT(IL.Quantity) >= 40 THEN 'Top'
    WHEN COUNT(IL.Quantity) >= 20 THEN 'Middle'
    ELSE 'Low'
  END AS Popularity
FROM Artist Art
JOIN Album Alb
  ON Art.ArtistId = Alb.ArtistId
JOIN Track T
  ON Alb.AlbumId = T.AlbumId
JOIN InvoiceLine IL
  ON T.TrackId = IL.TrackId
GROUP BY 1
ORDER BY 2 DESC ;


/* Query 3 */

SELECT
  G.Name Genre,
  ROUND(AVG(T.Milliseconds) / 60000, 2) "Number of Minutes"
FROM Genre G
JOIN Track T
  USING(GenreId)
GROUP BY 1
ORDER BY 2
LIMIT 5;


/* Query 4 */

SELECT
  STRFTIME('%Y', I.InvoiceDate) Year,
  COUNT(IL.TrackId) "Number of Tracks Bought"
FROM InvoiceLine IL
JOIN Invoice I
  ON I.InvoiceId = IL.InvoiceId
WHERE I.BillingCountry = 'USA'
GROUP BY 1
ORDER BY 1;