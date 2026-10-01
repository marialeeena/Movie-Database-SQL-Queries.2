#1115202200192  ΤΣΑΡΟΥΧΑ ΜΑΡΙΑ ΕΛΕΝΗ 
#1115202200266  ΕΡΙΠΑΡΕΛΗΣ ΔΗΜΗΤΡΙΟΣ 
#1115202100291  ΚΟΥΤΣΟΥΚΟΥ ΚΑΛΛΙΟΠΗ  

-- (1) 
-- Βρείτε τους τίτλους των ταινιών που παίζει ηθοποιός με επώνυμο “Allen” και το είδος της ταινίας είναι “Comedy”.

SELECT 
	DISTINCT title 
FROM 
	actor a, 
    role  r, 
    movie m, 
    movie_has_genre mhg,
    genre g
WHERE 
	a.actor_id = r.actor_id   
	AND r.movie_id =  m.movie_id  
	AND m.movie_id = mhg.movie_id 
	AND mhg.genre_id = g.genre_id 
	AND a.last_name = 'Allen'     
	AND g.genre_name = 'Comedy';

-- (2) 
-- Βρείτε τα επώνυμα των σκηνοθετών και τους τίτλους των ταινιών που έχουν σκηνοθετήσει, 
-- στις οποίες παίζει ηθοποιός με επώνυμο “Allen”, με την προϋπόθεση ότι αυτός ο σκηνοθέτης
-- έχει σκηνοθετήσει τουλάχιστον δύο διαφορετικά είδη ταινιών.

SELECT 
	DISTINCT d.last_name, 
    m.title
FROM 
	actor a, 
    role r, 
    movie m, 
    movie_has_genre mhg, 
    genre g, 
    movie_has_director mhd, 
    director d
WHERE
	a.actor_id = r.actor_id         
	AND r.movie_id =  m.movie_id        
	AND m.movie_id = mhg.movie_id       
	AND mhg.genre_id = g.genre_id       
    AND m.movie_id = mhd.movie_id       
    AND mhd.director_id = d.director_id 
    AND a.last_name = 'Allen'           
	AND d.director_id IN (
		SELECT 
			 director.director_id
		FROM 
			director, 
            movie_has_director, 
            movie, 
            movie_has_genre 
		WHERE
			director.director_id = movie_has_director.director_id  
			AND movie_has_director.movie_id = movie.movie_id           
			AND movie.movie_id = movie_has_genre.movie_id
		GROUP BY 
			director.director_id
		HAVING 
			count(DISTINCT movie_has_genre.genre_id) >= 2
	)
ORDER BY 
	last_name ASC, 
	title ASC;
     
	
-- (3) 
-- Βρείτε τα επώνυμα των ηθοποιών που, κατ αρχάς:
-- παίζουν σε τουλάχιστον μια ταινία που έχει σκηνοθετηθεί από σκηνοθέτη με το ίδιο επώνυμο, 
-- και κατά δεύτερον, 
-- έχουν παίξει σε τουλάχιστον μια ταινία με σκηνοθέτη με διαφορετικό επώνυμο που έχει ίδιο είδος
-- με αυτό άλλης ταινίας που δεν παίζουν αλλά έχει σκηνοθετήσει ο σκηνοθέτης με το ίδιο επώνυμο.   
 
SELECT 
	DISTINCT actor.last_name 
FROM 
	actor, 
    role, 
    movie, 
    movie_has_director, 
    director
WHERE
	actor.actor_id = role.actor_id 
	AND role.movie_id =  movie.movie_id 	
    AND movie.movie_id = movie_has_director.movie_id 
    AND movie_has_director.director_id = director.director_id 
    AND actor.last_name = director.last_name
intersect
SELECT 
	DISTINCT a.last_name 
FROM 
	actor a, 
    role r, 
    movie m, 
    movie_has_director mhm, 
    director d, 
    movie_has_genre mhg
WHERE
	a.actor_id = r.actor_id 
	AND r.movie_id =  m.movie_id 	
    AND m.movie_id = mhm.movie_id 
    AND mhm.director_id = d.director_id 
    AND a.last_name <> d.last_name 
    AND m.movie_id = mhg.movie_id 
    AND mhg.genre_id IN (
		SELECT 
			DISTINCT mhg2.genre_id
		FROM 
			movie_has_genre mhg2, 
            movie m2, 
            movie_has_director mhd2, 
            director d2
		WHERE			
			mhg2.movie_id = m2.movie_id 
			AND m2.movie_id = mhd2.movie_id 
			AND mhd2.director_id = d2.director_id 
			AND d2.last_name = a.last_name 
		);
        
-- (4) 
-- Ελέγξτε αν υπάρχει ταινία είδους “Drama” που έχει γυριστεί το 1995. (Το
-- ερώτημα θα πρέπει να επιστρέφει ως απάντηση μια σχέση με μια πλειάδα και
-- μια στήλη με τιμή “yes” ή “no”.). Απαγορεύεται η χρήση Flow Control Operators
-- (δηλαδή if, case, κλπ)        

SELECT 
	DISTINCT 'yes' AS 'answer'
FROM 
	movie, 
    movie_has_genre, 
    genre
WHERE
	movie.movie_id = movie_has_genre.movie_id    
    AND movie_has_genre.genre_id = genre.genre_id    
    AND movie.year = 1995                            
    AND genre.genre_name = 'Drama'
union    
SELECT 
	DISTINCT 'no' AS 'answer'
FROM 
	movie
WHERE NOT EXISTS (
    SELECT 
		*
	FROM 
		movie, 
        movie_has_genre, 
        genre
	WHERE
		movie.movie_id = movie_has_genre.movie_id   
		AND movie_has_genre.genre_id = genre.genre_id   
		AND movie.year = 1995                           
		AND genre.genre_name = 'Drama'
	);
    
    
-- (5) 
-- Βρείτε τα επώνυμα των ζευγών σκηνοθετών που έχουν συνσκηνοθετήσει την
-- ίδια ταινία μεταξύ του 2000 και του 2006, εφόσον οι δύο σκηνοθέτες
-- σχετίζονται με τουλάχιστον έξι διαφορετικά είδη ταινιών. Βεβαιωθείτε ότι κάθε
-- ζευγάρι τυπώνεται μία φορά (δηλαδή για παράδειγμα, μόνο ένα από τα (β1,β2)
-- και (β2,β1)) και ότι κάθε σκηνοθέτης δεν συνδυάζεται με τον εαυτό του. 
    
SELECT DISTINCT
	d1.last_name AS director_1,
	d2.last_name AS director_2
FROM 
	director d1 , 
    director d2,
    movie m1, 
    movie m2,
    movie_has_director mhd1, 
    movie_has_director mhd2,
    movie_has_genre mhg1, 
    movie_has_genre mhg2
    
WHERE
	-- different directors
	d1.director_id < d2.director_id   AND
	
	-- movies of director 1
	d1.director_id = mhd1.director_id AND
    mhd1.movie_id = m1.movie_id       AND
	m1.movie_id = mhg1.movie_id       AND
    
    -- movies of director 2
	d2.director_id = mhd2.director_id AND
    mhd2.movie_id = m2.movie_id       AND
	m2.movie_id = mhg2.movie_id       AND
	
	-- common movie
	m1.movie_id = m2.movie_id         AND

	-- that movie is between 
	m1.year BETWEEN 2000 AND 2006     AND
    
	
	(SELECT 
		count(DISTINCT mhg_1a.genre_id)
	FROM
		movie_has_genre mhg_1a
	WHERE
		mhg_1a.movie_id IN (
			SELECT movie_id
            FROM movie_has_director mhd_1a
            WHERE mhd_1a.director_id = d1.director_id
        )
        
    ) >= 6 
    
    AND
    
	(SELECT 
		count(DISTINCT mhg_2a.genre_id)
	FROM
		movie_has_genre mhg_2a
	WHERE
		mhg_2a.movie_id IN (
			SELECT movie_id
            FROM movie_has_director mhd_2a
            WHERE mhd_2a.director_id = d2.director_id
        )
        
    ) >= 6 ;

-- (6) 
-- Για κάθε ηθοποιό που έχει παίξει σε ακριβώς 3 ταινίες, βρείτε το όνομα και το
-- επώνυμο του καθώς και τον αριθμό των διαφορετικών σκηνοθετών που έχουν
-- οι ταινίες του.

SELECT
	a.first_name,
	a.last_name,
	count(DISTINCT d.director_id) AS "number of different directors"
FROM
	actor a,
	director d,
	genre g ,
	movie m,
	role r,
	movie_has_director mhd,
	movie_has_genre mhg
WHERE
	mhd.director_id = d.director_id
	AND mhd.movie_id = m.movie_id
	AND r.actor_id = a.actor_id
	AND r.movie_id = m.movie_id
	AND mhg.genre_id = g.genre_id
	AND mhg.movie_id = m.movie_id
GROUP BY
	a.first_name,
	a.last_name
HAVING
	count(DISTINCT m.movie_id)= 3
ORDER BY 
	last_name ;
      
      
-- (7) 
-- Για κάθε ταινία που έχει ακριβώς ένα είδος, βρείτε το είδος καθώς και τον
-- αριθμό των σκηνοθετών που έχουν σκηνοθετήσει αυτό το είδος.

SELECT DISTINCT 
	g.genre_id,
	count(DISTINCT mhd2.director_id) AS 'count'
FROM 
	movie m, 
    movie_has_genre mhg, 
    genre g, 
    movie_has_director mhd2, 
    movie_has_genre mhg2, 
    movie m2
WHERE 
	m.movie_id = mhg.movie_id
	AND mhg.genre_id = g.genre_id
	AND g.genre_id = mhg2.genre_id 
    AND mhg2.movie_id = m2.movie_id
	AND mhd2.movie_id = m2.movie_id
	AND m.movie_id IN (
      SELECT movie_id
      FROM movie_has_genre
      GROUP BY movie_id      
      HAVING COUNT(genre_id) = 1
  )
GROUP BY
	g.genre_id  ;

-- (8) 
-- Βρείτε τους κωδικούς των ηθοποιών που έχουν παίξει σε όλα τα είδη ταινιών.

SELECT 
	actor_id
FROM 
	actor
WHERE NOT EXISTS (
    SELECT 
		genre_id
    FROM 
		genre
    WHERE NOT EXISTS (
        SELECT *
        FROM 
			movie_has_genre
        WHERE 
			genre.genre_id = movie_has_genre.genre_id
			AND movie_has_genre.movie_id IN (
				SELECT movie_id
				FROM role
				WHERE role.actor_id = actor.actor_id
        )
    )
);	

		
-- (9)
-- Για κάθε ζεύγος ειδών (genre_id’s) ταινιών, βρείτε τον αριθμό των σκηνοθετών
-- που έχουν σκηνοθετήσει ταινίες και των δύο ειδών.

SELECT 
	mg1.genre_id AS genre_id_1,
    mg2.genre_id AS genre_id_2,
    count(DISTINCT d.director_id) AS Count
FROM 
	movie_has_director d,
    movie m,
    
    movie_has_genre mg1,
    
    movie_has_genre mg2
WHERE
	d.movie_id  = m.movie_id  AND
    mg1.movie_id = m.movie_id AND
    mg2.movie_id = m.movie_id AND
    mg1.genre_id < mg2.genre_id
GROUP BY
	mg1.genre_id , mg2.genre_id
ORDER BY
	mg1.genre_id , mg2.genre_id , Count DESC;



    
	
-- 10	
-- Για κάθε είδος και ηθοποιό, βρείτε τον αριθμό των ταινιών του είδους που έχει
-- παίξει ο ηθοποιός, εφόσον οι ταινίες αυτές συνολικά δεν έχουν σκηνοθέτη που
-- έχει σκηνοθετήσει και κάποιο άλλο είδος εκτός από αυτό.


SELECT 
	genre.genre_id, 
    actor.actor_id, 
    count(DISTINCT movie.movie_id) AS 'count'
FROM 
	actor, 
    role, 
    movie, 
    movie_has_genre, 
    genre,
    
    movie_has_director mhd, 
    
	movie_has_director mhd2, 
    movie m2, 
    movie_has_genre mhg2
WHERE
	actor.actor_id = role.actor_id 
	AND role.movie_id =  movie.movie_id 
	AND movie.movie_id = movie_has_genre.movie_id 
	AND movie_has_genre.genre_id = genre.genre_id 
	AND movie.movie_id  = mhd.movie_id 
	AND mhd.director_id = mhd2.director_id 
	AND mhd2.movie_id = m2.movie_id 
	AND m2.movie_id  = mhg2.movie_id 				
GROUP BY
	genre.genre_id, actor.actor_id
HAVING 
	count(DISTINCT mhg2.genre_id) = 1
ORDER BY
	genre.genre_id, 
    actor.actor_id;









	
	
	












