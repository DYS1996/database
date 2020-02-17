BEGIN;

CREATE TYPE PostView AS (
    postID INT,
    title TEXT,
    cDate TIMESTAMP WITH TIME ZONE,
    mDate TIMESTAMP WITH TIME ZONE,
    content TEXT,
    tags TEXT[]
);

CREATE TYPE CommentView AS (
    postID INT,
    commentID INT,
    authorEmail TEXT,
    cDate TIMESTAMP WITH TIME ZONE,
    content TEXT
);

COMMIT;