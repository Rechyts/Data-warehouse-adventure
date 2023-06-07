--For testing purpose for delete role and user
REASSIGN OWNED BY adv_dev1 TO postgres;
REASSIGN OWNED BY cleansing TO postgres;
DROP OWNED BY cleansing;
SET ROLE postgres;
DROP ROLE cleansing;
DROP ROLE adv_dev1;
COMMIT;