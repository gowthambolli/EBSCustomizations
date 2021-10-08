DECLARE
 L_BLOB BLOB;
 P_DATA CLOB
 ;
 
BEGIN
CREATE OR REPLACE EDITIONABLE VIEW "APPS"."NUAN_PSA_SO_HDR_ATTCHMENTS_V" ("ORDER_HEADER_ID", "ATTACHED_DOCUMENT_ID", "DOCUMENT_ID", "CATEGORY_ID", "CATEGORY", "DESCRIPTION", "FILE_NAME", "MEDIA_ID", "FILE_CONTENT_TYPE", "BLOB_DATA", "CHAR_SET_DATA") AS WITH
        FUNCTION CLOB_TO_BLOB (
            P_DATA IN CLOB
        ) RETURN BLOB AS
            L_BLOB          BLOB;
            L_DEST_OFFSET   PLS_INTEGER := 1;
            L_SRC_OFFSET    PLS_INTEGER := 1;
            L_LANG_CONTEXT  PLS_INTEGER := DBMS_LOB.DEFAULT_LANG_CTX;
            L_WARNING       PLS_INTEGER := DBMS_LOB.WARN_INCONVERTIBLE_CHAR;
     
            IF P_DATA IS NULL THEN
                RETURN NULL;
            END IF;
            DBMS_LOB.CREATETEMPORARY(
                                    LOB_LOC => L_BLOB,
                                    CACHE => TRUE
            );
            DBMS_LOB.CONVERTTOBLOB(
                                  DEST_LOB => L_BLOB,
                                  SRC_CLOB => P_DATA,
                                  AMOUNT => DBMS_LOB.LOBMAXSIZE,
                                  DEST_OFFSET => L_DEST_OFFSET,
                                  SRC_OFFSET => L_SRC_OFFSET,
                                  BLOB_CSID => DBMS_LOB.DEFAULT_CSID,
                                  LANG_CONTEXT => L_LANG_CONTEXT,
                                  WARNING => L_WARNING
            );
            
            RETURN L_BLOB;
            
        SELECT
        AD.PK1_VALUE           ORDER_HEADER_ID,
        AD.ATTACHED_DOCUMENT_ID,
        AD.DOCUMENT_ID,
        AD.CATEGORY_ID,
        DCT.USER_NAME           CATEGORY,
        DT.DESCRIPTION,
        FL.FILE_NAME,
        D.MEDIA_ID,
        FL.FILE_CONTENT_TYPE    FILE_CONTENT_TYPE,
        NVL(
            FILE_DATA,
            CLOB_TO_BLOB(
                FDLT.LONG_TEXT
            )
        )                       BLOB_DATA,    
        FL.ORACLE_CHARSET       CHAR_SET_DAT
    FROM
        FND_DOCUMENT_ENTITIES_TL    DET,
        FND_DOCUMENTS_TL            DT,
        FND_DOCUMENTS               D,
        FND_DOCUMENT_CATEGORIES_TL  DCT,
        FND_ATTACHED_DOCUMENTS      AD,
        FND_LOBS                    FL,
        FND_DOCUMENTS_LONG_TEXT     FDLT
    WHERE
            1 = 1
        AND AD.ENTITY_NAME = 'OE_ORDER_HEADERS'
        AND FL.FILE_ID (+) = D.MEDIA_ID
        AND FDLT.MEDIA_ID (+) = D.MEDIA_ID
        AND D.DOCUMENT_ID = AD.DOCUMENT_ID
        AND DT.DOCUMENT_ID = D.DOCUMENT_ID
        AND DT.LANGUAGE = USERENV(
            'LANG'
        )
        AND DCT.CATEGORY_ID = D.CATEGORY_ID
        AND DCT.LANGUAGE = USERENV(
            'LANG'
        )
        AND AD.ENTITY_NAME = DET.DATA_OBJECT_CODE
        AND DET.LANGUAGE = USERENV(
            'LANG'
        )   
;
END;

