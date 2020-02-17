BEGIN;
ALTER TABLE Posts ADD COLUMN fullTextSearch TSVECTOR GENERATED ALWAYS AS (setweight(to_tsvector('english', coalesce(title,'')),'A') || setweight(to_tsvector('english', coalesce(content,'')),'C')) STORED;
CREATE INDEX ON Posts USING GIN(fullTextSearch);


CREATE FUNCTION getPostsByFTS(query TEXT, pageSize INT, page INT) RETURNS setof PostView SECURITY DEFINER AS $$
DECLARE
    ofs INT = (page -1) * pagesize;
    query TSQUERY = websearch_to_tsquery('english', query);
BEGIN
    RETURN QUERY SELECT p.postID AS postID, title, cDate, mDate, substring(content for 75), array_remove(array_agg(tag), NULL) AS tags FROM Posts p LEFT JOIN Tags t ON p.postID = t.postID WHERE fullTextSearch @@ query GROUP BY p.postID ORDER BY ts_rank_cd(fullTextSearch,query,16|32) DESC, postID DESC LIMIT pagesize OFFSET ofs;
    RETURN;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION getPostsCountByFTS(query TEXT) RETURNS INT SECURITY DEFINER AS $$
DECLARE 
    cnt INT = -1;
    query TSQUERY = websearch_to_tsquery('english', query);
BEGIN
    SELECT count(*) INTO cnt FROM Posts WHERE fullTextSearch @@ query;
    RETURN cnt;
END;
$$ LANGUAGE plpgsql;
COMMIT;
