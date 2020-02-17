BEGIN;

SET search_path TO pgtap, public;
SET client_min_messages TO WARNING;

SELECT plan(45);

TRUNCATE Posts,Tags,Comments,Users RESTART IDENTITY CASCADE;

-- constraint
SELECT lives_ok($$INSERT INTO Posts(title, content) VALUES('title1', 'perfect content1!')$$, 'table Posts can be inserted');

SELECT lives_ok($$INSERT INTO Posts(title, content) VALUES('title2', 'perfect content2!')$$, 'another table Posts can be inserted');

SELECT throws_ok($$INSERT INTO Posts(title, content) VALUES('title1', 'same title cannot happen')$$,'23505',NULL, 'same title cannot exist');

SELECT throws_ok($$INSERT INTO Posts(title, content) VALUES('a', 'too short title!')$$, '23514', NULL, 'too short title!');

SELECT throws_ok($$INSERT INTO Posts(title, content) VALUES('too longggggggggggggggggggggg title', 'too long title')$$, '23514', NULL, 'too long title');

SELECT throws_ok($$INSERT INTO Posts(title, content) VALUES('title3', 'a')$$,'23514', NULL, 'too short content');

SELECT throws_ok($$INSERT INTO Posts(title, content) VALUES('title4', repeat('a', 200000))$$, '23514', NULL, 'too long content');



SELECT lives_ok($$INSERT INTO Tags(postID, tag) VALUES(1, 'tag1')$$, 'insert tags function properly');

SELECT throws_ok($$INSERT INTO Tags(postID, tag) VALUES(1, 'a')$$, '23514', NULL, 'tags cannot be too short');

SELECT throws_ok($$INSERT INTO Tags(postID, tag) VALUES(1, 'longggggggggggg,n')$$, '23514', NULL, 'tags cannot be too long');

SELECT throws_ok($$INSERT INTO Tags(postID, tag) VALUES(1, 'tag1')$$, '23505', NULL, 'a post cannot have same tags');

SELECT lives_ok($$INSERT INTO Tags(postID, tag) VALUES(1, 'tag2')$$, 'insert another tags function properly');

SELECT lives_ok($$INSERT INTO Tags(postID, tag) VALUES(1, 'tag3')$$, 'insert 3 tags function properly');
SELECT lives_ok($$INSERT INTO Tags(postID, tag) VALUES(1, 'tag4')$$, 'insert 4 tags function properly');

SELECT lives_ok($$INSERT INTO Tags(postID, tag) VALUES(1, 'tag5')$$, 'insert 5 tags function properly');

SELECT throws_ok($$INSERT INTO Tags(postID, tag) VALUES(1, 'tag6')$$, 'TRG01', NULL, 'a post can have at most 5 tags');

SELECT lives_ok($$INSERT INTO Tags(postID, tag) VALUES(2, 'tag4')$$, 'insert 5 tags function properly');

SELECT lives_ok($$INSERT INTO Comments(postID, content, authorEmail) VALUES(1, 'comment1', 'email1@gmail.com')$$, 'insert comments should work');

SELECT throws_ok($$INSERT INTO Comments(postID, content, authorEmail ) VALUES(1, 'a', 'email3@gmail.com')$$, '23514', NULL, 'comment cannot be too short');

SELECT throws_ok($$INSERT INTO Comments(postID, content, authorEmail) VALUES(1, repeat('a', 800), 'email4@gamil.com')$$, '23514', NULL, 'comment cannot be too long');

SELECT lives_ok($$INSERT INTO Comments(postID, content, authorEmail) VALUES(2, 'comment2', 'email2@hotmail.com')$$, 'insert comments should work');



SELECT lives_ok($$INSERT INTO Users(userName, passWord) VALUES ('webAdmin', '\xe428346da0067e05c95229ee3b8e03af8a9482857d4198b990daf7e98676a15f')$$, 'insert into user should work properly');

SELECT throws_ok($$INSERT INTO Users(userName, passWord) VALUES ('a', '\xe428346da0067e05c95229ee3b8e03af8a9482857d4198b990daf7e98676a15f')$$, 23514, NULL, 'too short username');

SELECT throws_ok($$INSERT INTO Users(userName, passWord) VALUES (repeat('a',800), '\xe428346da0067e05c95229ee3b8e03af8a9482857d4198b990daf7e98676a15f')$$, 23514, NULL, 'too long username');

SELECT throws_ok($$INSERT INTO Users(userName, passWord, privilege) VALUES ('webAdmin', '\xe428346da0067e05c95229ee3b8e03af8a9482857d4198b990daf7e98676a15f',0)$$, 23505, NULL, 'same username cannot exist');

SELECT throws_ok($$INSERT INTO Users(userName, passWord) VALUES ('goodName', '\xe428346d05c95229ee3b8e03af8a9482857d4198b990daf7e98676a15f')$$, 23514, NULL, 'passWord too short');

SELECT throws_ok($$INSERT INTO Users(userName, passWord) VALUES ('goodName', '\xe176238712685681623428346d05c95229ee3b8e03af8a9482857d4198b990daf7e98676a15f')$$, 23514, NULL, 'passWord too long');

SELECT throws_ok($$INSERT INTO Users(userName, passWord) VALUES ('goodName', '\x1asd76238712685681623428346d05c95229ee3b8e03af8a9482857d4198b990daf7e98676a15f')$$, 22023, NULL, 'passWord in invalid type');

-- api

SELECT bag_eq($$SELECT * FROM getPostByID(1)$$, $$VALUES(1,'title1',CURRENT_TIMESTAMP, NULL::DATE,'perfect content1!', ARRAY['tag1','tag2','tag3','tag4','tag5'])$$, 'function getPostByID(1) can return properly');

SELECT bag_eq($$SELECT * FROM getPostsByPage(3, 1)$$, $$VALUES(1,'title1', CURRENT_TIMESTAMP, NULL::DATE, 'perfect content1!...', ARRAY['tag1', 'tag2', 'tag3', 'tag4', 'tag5']),(2,'title2',CURRENT_TIMESTAMP, NULL::DATE,'perfect content2!...', ARRAY['tag4']::text[])$$, 'function getPostByPage(3,1) should return all 2 posts properly');


SELECT ok(deletePost, 'deletePost() successfully delete post') FROM deletePost(1);

SELECT ok(NOT deletePost, 'deletePost() cannot delete post that does not exist') FROM deletePost(111);

SELECT ok(updatePost, 'updatePost() can successfully work') FROM updatePost(2, 'title2_new','content2_new', ARRAY[]::TEXT[]);

SELECT bag_eq($$SELECT * FROM getPostByID(2)$$, $$VALUES(2,'title2_new',CURRENT_TIMESTAMP, CURRENT_TIMESTAMP,'content2_new', ARRAY[]::TEXT[])$$, 'updatePost() really changes posts with mDate');

SELECT is(getPostsCount,1, 'getPostsCount() report correct number of posts in db') FROM getPostsCount();

-- reset serial

TRUNCATE Posts,Tags,Comments,Users RESTART IDENTITY CASCADE;

SELECT is(insertPost, 1, 'insertPost() returns new pid of post inserted') FROM insertPost('title1', 'perfect content1!', ARRAY['tag1','tag2']);

SELECT bag_eq($$SELECT * FROM getPostByID(1)$$, $$VALUES(1,'title1',CURRENT_TIMESTAMP,NULL::DATE,'perfect content1!',ARRAY['tag1','tag2'])$$, 'after insert post, we should be able to retrieve it' );

SELECT is(insertComment, 1, 'insertComment() should work correctly') FROM insertComment(1, 'comment1', 'email1@hotmail.com');

SELECT ok(NOT deleteComment, 'cannot delete comments that do not exist') FROM deleteComment(111);

SELECT ok(updateComment, 'updateComment works smoothly') FROM updateComment(1, 'new content 1', 'email2@gmail.com');


SELECT is(getCommentsCount, 1, 'getCommentsCount() report correct number of comments') FROM getCommentsCount(1);

SELECT bag_eq($$SELECT * FROM getCommentsByPage(1, 3, 1)$$, $$VALUES(1, 1, 'email2@gmail.com', CURRENT_TIMESTAMP, 'new content 1')$$, 'we should be able to get most recent comments in db');

SELECT is(getPostsCountByFTS, 1, 'Full Text Search should work') FROM getPostsCountByFTS('perfect');

SELECT is(insertUser, 1, 'insertUser works properly') FROM insertUser('webAdmin', '\xe428346da0067e05c95229ee3b8e03af8a9482857d4198b990daf7e98676a15f');

SELECT bag_eq($$SELECT * FROM getUser('webAdmin', '\xe428346da0067e05c95229ee3b8e03af8a9482857d4198b990daf7e98676a15f')$$, $$VALUES(1,'webAdmin', 100)$$, 'we can retrieve inserted user');


SELECT * FROM finish();
ROLLBACK;
