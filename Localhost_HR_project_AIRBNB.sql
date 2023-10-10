--�α���(��ȭ��ȣ)�� �ϴ� ��� 
CREATE OR REPLACE PROCEDURE login
(
    pcountry member.country%TYPE
    ,pmem_phone member.mem_phone%TYPE
)
IS
    vmem_phonecheck number(1);
    
BEGIN
    SELECT COUNT(*) INTO vmem_phonecheck
    FROM member
    WHERE mem_phone = pmem_phone;
    
IF vmem_phonecheck = 1 THEN --��ȭ��ȣ�� ������ ���̹Ƿ� ��ġ�ϸ� �α��� ����
DBMS_OUTPUT.PUT_LINE('�α��� ����!!!!');

ELSE
DBMS_OUTPUT.PUT_LINE('������ �������� �ʽ��ϴ�. ȸ������ ��Ź�帳�ϴ�.');
END IF;
END;

EXEC login('�ѱ�','01096336892'); --�α��μ���

EXEC login('�ѱ�','01096336890'); --�α��� ����

--�α���(�̸���)�� �ϴ� ���
CREATE OR REPLACE PROCEDURE login_em
(
    pmem_email member.mem_email%TYPE
)
IS
    vmem_emailcheck number(1);
    
BEGIN
    SELECT COUNT(*) INTO vmem_emailcheck
    FROM member
    WHERE mem_email = pmem_email;
    
IF vmem_emailcheck = 1 THEN
DBMS_OUTPUT.PUT_LINE('�α��� ����!!!!');

ELSE
DBMS_OUTPUT.PUT_LINE('������ �������� �ʽ��ϴ�. ȸ������ ��Ź�帳�ϴ�.');
END IF;
END;

EXEC login_em('jek3118@naver.com');

EXEC login_em('lavender@naver.com');


--ȸ������ 
CREATE OR REPLACE PROCEDURE  up_inssign
(
    pmem_name member.mem_name%type
    ,pbirth member.birth%type
    ,pmem_email member.mem_email%type
    ,pmem_phone member.mem_phone%type
    ,pcountry member.country%type
)
IS
   vmember_code member.mem_code%type;
BEGIN
    --ȸ���ڵ尡 ME1�������� ������ �Ǿ��ִµ�, ȸ���ڵ�� ȸ������ �þ ���� 1�� �߰��Ǿ�� �ϱ� ������
    --����° ���ڸ� �߶�ͼ� �� �߶�� ���ڸ� �ѹ��� �ְ�, �� ���� �ִ밪�� �̾Ƽ� +1���� ���� ȸ���ڵ庯���� ������ ���ݴϴ�.
    SELECT 'ME' || TO_CHAR( NVL( MAX( TO_NUMBER( SUBSTR( mem_code, 3 ) ) ), 0 ) + 1 ) INTO vmember_code
    FROM member;
    
    INSERT INTO member(mem_code,mem_name,birth,mem_email,mem_phone,country) 
    values (vmember_code,pmem_name,pbirth,pmem_email,pmem_phone,pcountry);
EXCEPTION
        WHEN VALUE_ERROR THEN
            RAISE_APPLICATION_ERROR(-20011, '>�Է��Ͻ� ������ ���� �ʹ� Ů�ϴ�.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20012, '>ȸ�� ������ �Ұ��� �մϴ�.');   
END;

EXEC up_inssign('������','990825','qwer14@naver.com','01012349999','�ѱ�');

SELECT *
FROM MEMBER;

--ȸ������ ����  
CREATE OR REPLACE PROCEDURE UP_memupd
(
    pmem_code member.mem_code%type
     ,pmem_name member.mem_name%type := NULL
    ,pmem_email member.mem_email%type := NULL
    ,pmem_phone member.mem_phone%type := NULL
   ,pmem_check member.mem_check%type := NULL
   ,pmem_loc member.mem_loc%type    := NULL
   ,pemergency member.emergency%type := NULL
    ,pbank member.bank%type  := NULL
    ,paccount member.account%type := NULL
)
IS
    vmem_code member.mem_code%type;
    vmem_name member.mem_name%type;
    vmem_email member.mem_email%type;
    vmem_phone member.mem_phone%type;
    vmem_check member.mem_check%type;
    vmem_loc member.mem_loc%type;
    vemergency member.emergency%type;
    vbank member.bank%type;
    vaccount member.account%type;

BEGIN
    SELECT mem_name, mem_email, mem_phone, mem_check, mem_loc, emergency, bank, account 
    INTO vmem_name, vmem_email, vmem_phone, vmem_check, vmem_loc, vemergency, vbank, vaccount
    FROM member
    WHERE mem_code = pmem_code;


    UPDATE member
    SET 
         mem_name = NVL(pmem_name, vmem_name) --NVL�ڵ带 ����� �����ϰ� ���� ���� ���� �ִٸ�, ������ �����Ͱ� ������ ����
         ,mem_email = NVL(pmem_email, vmem_email)
        ,mem_phone = NVL(pmem_phone,vmem_phone)
         ,mem_check = NVL(pmem_check,vmem_check)
         ,mem_loc = NVL(pmem_loc,vmem_loc)
         ,emergency = NVL(pemergency,vemergency)
        ,bank = NVL(pbank,vbank)
        ,account = NVL(paccount,vaccount)
    WHERE mem_code = pmem_code;
    COMMIT;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20002, '>��ġ�ϴ� ȸ�������� ã���� �����ϴ�.');
        WHEN VALUE_ERROR THEN
            RAISE_APPLICATION_ERROR(-20003, '>�Է��Ͻ� ������ ���� �ʹ� Ů�ϴ�.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20004, '>ȸ�� ������ �Ұ��� �մϴ�.');
END;


EXEC UP_memupd('ME41','�ڴ��','pjw8888@gmail.com','01022223333','Y','���￪ 3�� �ⱸ','01055556666','�츮����','555555555'); --�̸����� �� �߰����
EXEC UP_memupd( pmem_code =>'ME41', pbank =>'īī����ũ' ); --Ư�� ���� ������ ���

EXEC UP_memupd('ME41','�ڴ��','pjw8888@gmail.com','010222233330000000000000000','Y','���￪ 3�� �ⱸ','01055556666','�츮����','555555555');



--ȸ�� �����ϱ�
CREATE OR REPLACE PROCEDURE mem_del
(
    pmem_phone in member.mem_phone%TYPE
)
IS
BEGIN
    DELETE FROM member
    WHERE pmem_phone = mem_phone;
    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20005, '>��ġ�ϴ� ȸ�������� ã���� �����ϴ�.');
    WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20006, '>ȸ��Ż�� �Ұ��� �մϴ�.');
END mem_del;

EXECUTE mem_del('01022223333');


select *
from member;
--------------------------------------------------------------------------------

--------------------------------------------------------
    1. ���ҵ�� 
--------------------------------------------------------
1. ���ҵ�� 

1) �ʼ��������
CREATE OR REPLACE PROCEDURE up_insRoom  
(   
    pcountry room.country%TYPE,
    pref_policy room.ref_policy%TYPE,
    prm_type room.rm_type%TYPE, 
    pspace room.space%TYPE,
    prm_name room.rm_name%TYPE,
    pmaxguest room.maxguest%TYPE, 
    prm_info room.rm_info%TYPE,
    pprice room.price%TYPE,
    prm_loc room.rm_loc%TYPE,
    pbedroom room.bedroom%TYPE,
    pbed room.bed%TYPE, 
    pbathroom room.bathroom%TYPE,
    padmin_code room.admin_code%TYPE   
)
IS
    vrm_code room.rm_code%TYPE; 
BEGIN     
    -- �����ڵ� �ٿ��ֱ� 
    SELECT 'RM' 
        || TO_CHAR( NVL( MAX( TO_NUMBER( SUBSTR( rm_code, 3 ) ) ), 0 ) + 1 )
    INTO vrm_code
    FROM room; 
    
    -- �� ���� 
    INSERT INTO room (rm_code, country, ref_policy, rm_type, space 
                 , rm_name, maxguest, rm_info , price
                 , rm_loc,bedroom,bed,bathroom ,admin_code)
        VALUES( vrm_code, pcountry, pref_policy, prm_type, pspace
            , prm_name , pmaxguest , prm_info, pprice 
            ,prm_loc, pbedroom, pbed, pbathroom, padmin_code);
    COMMIT; 
    
    --Ȯ�� 
    DBMS_OUTPUT.PUT_LINE(vrm_code||','|| pcountry ||','|| pref_policy||','|| prm_type||','|| pspace
            ||','|| prm_name ||','|| pmaxguest ||','|| prm_info ||','|| pprice 
            ||','|| prm_loc||','||pbedroom||','|| pbed||','|| pbathroom||','||padmin_code);
            
    DBMS_OUTPUT.PUT_LINE('���� �⺻������ �Է��߽��ϴ�! �������� ������ �Է��� �ּ���! '); 

END ; --Procedure UP_INSRULE��(��) �����ϵǾ����ϴ�.

[����]
EXEC up_insRoom ('�̱�','����','�غ��ٷξ�','���ν�','�غ� �� ����Ʈ126',4,'�ÿ��� �ٴ�ٶ��� �Բ� ��հ� ������ ���������! ��������� �����Դϴ�.',331242,'�Ͽ���, �̱�',2,3,2,'AD7'); 

SELECT *
FROM room;

2) �������  
CREATE OR REPLACE PROCEDURE up_insPhoto 
( 
  ppath1 photo.path%TYPE,
  ppath2 photo.path%TYPE,
  ppath3 photo.path%TYPE,
  ppath4 photo.path%TYPE,
  ppath5 photo.path%TYPE
)
IS 
    vrm_code room.rm_code%TYPE; 
    vimageindex VARCHAR2(10);     
BEGIN
    -- ���ڵ� : ���� �����ϰ� �ִ� ���� ��ȣ 
    SELECT 'RM' || TO_CHAR( NVL( MAX( TO_NUMBER( SUBSTR( rm_code, 3 ) ) ), 0 ) )
    INTO vrm_code
    FROM room;
    
    -- �����ڵ� 
    SELECT NVL( MAX( TO_NUMBER( SUBSTR( photo_code, 4 ) ) ), 0 ) + 1 
    INTO vimageindex 
    FROM photo; 

    -- ������ ���� �ּ� ����  
    INSERT INTO photo VALUES ('PIC'||TO_CHAR(vimageindex), ppath1, vrm_code ) ;
    vimageindex :=  vimageindex+1; 
    
    INSERT INTO photo VALUES ('PIC'||TO_CHAR(vimageindex), ppath2, vrm_code ) ;
    vimageindex :=  vimageindex+1;
    
    INSERT INTO photo VALUES ('PIC'||TO_CHAR(vimageindex), ppath3, vrm_code ) ;
    vimageindex :=  vimageindex+1;
    
    INSERT INTO photo VALUES ('PIC'||TO_CHAR(vimageindex), ppath4, vrm_code ) ;
    vimageindex :=  vimageindex+1;
    
    INSERT INTO photo VALUES ('PIC'||TO_CHAR(vimageindex), ppath5, vrm_code ) ;
    vimageindex :=  vimageindex+1;
    
    DBMS_OUTPUT.PUT_LINE('���� ������Ͽ� �����Ͽ����ϴ�.'); 
    COMMIT; 
END; --Procedure UP_INSPHOTO��(��) �����ϵǾ����ϴ�.

[����] 
EXEC up_insPhoto ('C:\Class\WorkSpace\OracleClass\�����̹���.�ٴ�.jpg','C:\Class\WorkSpace\OracleClass\�����̹���.��.jpg','C:\Class\WorkSpace\OracleClass\�����̹���.�ٶ�.jpg','C:\Class\WorkSpace\OracleClass\�����̹���.�ĵ�.jpg','C:\Class\WorkSpace\OracleClass\�����̹���.�ظ�.jpg') ; 

SELECT *
FROM photo;

3) ���һ���
CREATE OR REPLACE PROCEDURE up_updRoomStatus
(
    prm_code room.rm_code%TYPE,
    prm_status room.rm_status%TYPE
)
IS
    vrm_status room.rm_status%TYPE;
    v_no_more_visible EXCEPTION ; 
BEGIN
    SELECT rm_status INTO vrm_status
    FROM room
    WHERE rm_code = prm_code;

    IF vrm_status = '��Ȱ��ȭ' THEN
        RAISE v_no_more_visible;
    ELSE 
        UPDATE room
        SET rm_status = prm_status
        WHERE rm_code = prm_code;
        
        -- ���, ������� ȭ�鿡 ���� ����� �� WHERE �������� ������, �ȳ�����
    IF prm_status = '��Ȱ��ȭ' THEN
            --����
        DELETE FROM WISHLIST WHERE rm_code = prm_code;
        DELETE FROM REGISTER WHERE rm_code = prm_code;
        DELETE FROM RULESET WHERE rm_code = prm_code;
        DELETE FROM FACSET WHERE rm_code = prm_code;
        DELETE FROM PHOTO WHERE rm_code = prm_code;
        DELETE FROM DCSET WHERE rm_code = prm_code;
        DELETE FROM FEESET WHERE rm_code = prm_code;
            -- ���� ���� ����
            UPDATE reserve
            SET res_status = '�������'
            WHERE rm_code = prm_code;
        END IF;
    END IF;
EXCEPTION
    WHEN v_no_more_visible THEN 
        RAISE_APPLICATION_ERROR(-20012, '�̹� ��Ȱ��ȭ�� �����Դϴ�') ; 
        ROLLBACK;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('��Ÿ ���� �߻�');
        ROLLBACK;
END;
    
[����] 
EXEC up_updRoomStatus( 'RM33', '�����' );

SELECT rm_code, rm_status
FROM room;

SELECT *
FROM wishlist;
SELECT *
FROM reserve;


---------------------------------------------------------------------------
3. �������� ����
---------------------------------------------------------------------------

1) ���Ҹ� ���� 
CREATE OR REPLACE PROCEDURE up_updRoomname
(
    prm_code room.rm_code%TYPE,
    prm_name room.rm_name%TYPE
) 
IS 
BEGIN
    IF LENGTH(prm_name) > 50 THEN -- ���� ���̸� �ʰ��ϴ� ���
        RAISE VALUE_ERROR; -- VALUE_ERROR ���� �߻�
    
    ELSE -- ������ ���� ������ ���
        UPDATE room 
        SET rm_name = prm_name 
        WHERE rm_code = prm_code;
    COMMIT; 
    END IF; 
    
    DBMS_OUTPUT.PUT_LINE('���� �̸��� �����߽��ϴ�!   �����ڵ�'||prm_code);
    DBMS_OUTPUT.PUT_LINE('����� �����̸� : '||prm_name);

EXCEPTION 
    WHEN VALUE_ERROR THEN 
        RAISE_APPLICATION_ERROR(-20001, 'TOO LONG VALUE') ;
        DBMS_OUTPUT.PUT_LINE('>���� �̸��� 50�� ���Ϸ� �Է��ϼ���.');
    WHEN OTHERS THEN 
        RAISE_APPLICATION_ERROR(-20002, 'UNKNOWN PROBLEM') ; 
        DBMS_OUTPUT.PUT_LINE('�ش� ��û�� ���������� ó���� �� �����ϴ�');

END; --Procedure UP_UPDROOMNAME��(��) �����ϵǾ����ϴ�.

[����] 
EXEC up_updRoomname('RM13', '�츮��' ); 
EXEC up_updRoomname('RM17', '�츮���츮���츮���츮���츮���츮���츮�츮���츮���츮���츮���츮���츮���츮���츮���츮�츮���츮���츮���츮���츮���츮���츮���츮���츮���츮���츮���츮���츮���츮���츮���츮��' )  ; 
--UNKNOWN PROBLEM

SELECT rm_code, rm_name
FROM room;
DESC room

2) ���Ҽ��� ���� 
CREATE OR REPLACE PROCEDURE up_updRoomloc
(
    prm_code room.rm_code%TYPE,
    prm_info room.rm_info%TYPE
)
IS
BEGIN
    IF LENGTH(prm_info) > 200 THEN -- ���� ���̰� ���� ���̸� �ʰ��ϴ� ���
        RAISE VALUE_ERROR; -- VALUE_ERROR ���� �߻�
    ELSE -- ���� ���̰� ���� ���� ������ ���
        UPDATE room
        SET rm_info = prm_info
        WHERE rm_code = prm_code;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('���� ������ �����߽��ϴ�! �����ڵ�'||prm_code);
        DBMS_OUTPUT.PUT_LINE('����� ���Ҽ��� : '||prm_info);
    END IF;
EXCEPTION
    WHEN VALUE_ERROR THEN 
    RAISE_APPLICATION_ERROR(-20001, 'TOO LONG VALUE') ;
    DBMS_OUTPUT.PUT_LINE('>���� �̸��� 50�� ���Ϸ� �Է��ϼ���.');
    
    WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-22222, '�ش� ��û�� ���������� ó���� �� �����ϴ�.');
END; 

[����] 
EXEC up_updRoomloc('RM16', '������ �ٲ㺾�ô�'); 
EXEC up_updRoomloc('RM16', '������ �ٲ㺾�ôټ����� �ٲ㺾�ôټ����� �ٲ㺾�ôټ����� �ٲ㺾�ôټ����� �ٲ㺾�ôټ����� �ٲ㺾�ôټ����� �ٲ㺾�ôټ����� �ٲ㺾�ôټ����� �ٲ㺾�ôټ����� �ٲ㺾�ôټ����� �ٲ㺾�ôټ����� �ٲ㺾�ôټ����� �ٲ㺾�ôټ����� �ٲ㺾�ôټ����� �ٲ㺾�ôټ����� �ٲ㺾�ôټ����� �ٲ㺾�ôټ����� �ٲ㺾�ôټ����� �ٲ㺾�ôټ����� �ٲ㺾�ôټ����� �ٲ㺾�ôټ����� �ٲ㺾�ôټ����� �ٲ㺾�ôټ����� �ٲ㺾�ôټ����� �ٲ㺾�ô�'); 

SELECT rm_code, rm_info
FROM room;


3) �Խ�Ʈ�� 
CREATE OR REPLACE PROCEDURE up_updMaxguest
    (
    prm_code room.rm_code%TYPE,
    pupdown VARCHAR2 
    )
IS
    vmaxguest room.maxguest%TYPE;
BEGIN
    SELECT maxguest INTO vmaxguest
    FROM room
    WHERE rm_code = prm_code ;

    IF pupdown = '+' THEN 
     vmaxguest := vmaxguest + 1; 
     DBMS_OUTPUT.PUT_LINE('�Խ�Ʈ�� 1������');
    ELSE 
     vmaxguest := vmaxguest - 1; 
     DBMS_OUTPUT.PUT_LINE('�Խ�Ʈ�� 1����');
    END IF;
     
    UPDATE room 
        SET maxguest = vmaxguest
    WHERE rm_code = prm_code;
    
    COMMIT; 
    DBMS_OUTPUT.PUT_LINE('�� �Խ�Ʈ�� '||vmaxguest);

END; --Procedure UP_UPDMAXGUEST��(��) �����ϵǾ����ϴ�.

[����] 
EXEC up_updMaxguest('RM17', '+'); 
EXEC up_updMaxguest('RM17', '-'); 

SELECT rm_code, maxguest
FROM room
WHERE rm_code = 'RM17'; 



4)�ּ� ���� 
CREATE OR REPLACE PROCEDURE up_updRoomloc
(
    prm_code room.rm_code%TYPE, 
    prm_loc room.rm_loc%TYPE
)
IS 
BEGIN 
    UPDATE room
        SET rm_loc = prm_loc
    WHERE rm_code = prm_code; 

    COMMIT; 
    DBMS_OUTPUT.PUT_LINE('�ּҸ� �����߽��ϴ�!�����ڵ�'||prm_code);
    DBMS_OUTPUT.PUT_LINE('����� �ּ� : '||prm_loc);
END ; -- Procedure UP_UPDROOMLOC��(��) �����ϵǾ����ϴ�.

[����] 
EXEC UP_UPDROOMLOC('RM3', '������, ����Ư����, �ѱ�');

SELECT rm_code, rm_loc
FROM room;

5) �������� & ���డ�ɰ��� ���� 
CREATE OR REPLACE PROCEDURE up_updRoomtype
(
    prm_code room.rm_code%TYPE, 
    prm_type room.rm_type%TYPE, 
    pspace room.space%TYPE 
)
IS 
    vrm_type room.rm_type%TYPE;
    vspace room.space%TYPE ; 
BEGIN 
    SELECT rm_type,space INTO vrm_type, vspace 
    FROM room 
    WHERE rm_code = prm_code; 
    
    UPDATE room
        SET rm_type = NVL(prm_type, vrm_type) 
            , space = NVL(pspace, vspace) 
    WHERE rm_code = prm_code;  
    COMMIT; 
    
    DBMS_OUTPUT.PUT_LINE('���������� �����߽��ϴ�!�����ڵ� : '||prm_code);
    DBMS_OUTPUT.PUT_LINE('����� �������� : '||prm_type|| '  /   ���డ�ɰ��� : '|| pspace);
END ; --Procedure UP_UPDROOMTYPE��(��) �����ϵǾ����ϴ�.


[����] 
EXEC UP_UPDROOMTYPE('RM12', '��������', '���ν�') ; 

SELECT rm_code, rm_type, space
FROM room 
WHERE rm_code = 'RM12' ; 

6) ħ��&ħ��&��� 
CREATE OR REPLACE PROCEDURE up_updNecessity 
(
    prm_code IN room.rm_code%TYPE,
    pupdown_bedroom NUMBER DEFAULT 0,  
    pupdown_bed NUMBER DEFAULT 0, 
    pupdown_bathroom NUMBER DEFAULT 0 
)
IS
    vbedroom room.bedroom%TYPE;
    vbed room.bed%TYPE;
    vbathroom room.bathroom%TYPE; 
BEGIN
    SELECT bedroom, bed, bathroom INTO vbedroom, vbed, vbathroom
    FROM room
    WHERE rm_code = prm_code ;
    
    vbedroom := vbedroom + pupdown_bedroom ; 
    vbed := vbed + pupdown_bed; 
    vbathroom := vbathroom + pupdown_bathroom; 

    IF (vbedroom < 1 OR vbed < 0 OR vbathroom < 1) THEN
        RAISE_APPLICATION_ERROR(-20001, '�� �̻� �� �� �����ϴ�');
    END IF;

    UPDATE room 
    SET bedroom = vbedroom, bed = vbed, bathroom = vbathroom
    WHERE rm_code = prm_code; 
    COMMIT; 
    
    DBMS_OUTPUT.PUT_LINE('�� ħ�� �� '|| vbedroom);
    DBMS_OUTPUT.PUT_LINE('�� ħ�� �� '|| vbed);
    DBMS_OUTPUT.PUT_LINE('�� ��� �� '|| vbathroom);
END;


[����] 
EXEC up_updNecessity('RM17', 1,-1,2) ; --213
EXEC up_updNecessity('RM17', pupdown_bedroom => 1, pupdown_bed => 2 ) ; --333
EXEC UP_UPDNECESSITY('RM17', pupdown_bed =>-1) ; 

SELECT bedroom, bed, bathroom
FROM room 
WHERE rm_code = 'RM17' --232 141

7) 1�ڴ� ���
CREATE OR REPLACE PROCEDURE up_updPrice
(
    prm_code room.rm_code%TYPE, 
    pprice room.price%TYPE
)
IS 
    vavg_price NUMBER(10) ; 
BEGIN 
    SELECT ROUND(AVG(price)) into vavg_price
    FROM room ; 
    
    IF pprice > vavg_price THEN 
        DBMS_OUTPUT.PUT_LINE('�⺻ ����� ���߾� ���� ���ɼ��� ����������
                                ȸ���� ������ ���信 ���� ����� �����ϸ� ������� ������ �� �ֽ��ϴ�.');
    ELSE 
        DBMS_OUTPUT.PUT_LINE('����Ʈ ������� �� ���� ������ �ø�����.
                                ����� �ִ� ����� ������ ������ �� ���� �ް� ��������� 
                                �� ���� ������ �ø��� �� �ֵ��� �����غ� ���͵帮�ڽ��ϴ�.');
    END IF ; 
    
    UPDATE room
    SET price = pprice
    WHERE rm_code = prm_code; 
    COMMIT; 
    
    DBMS_OUTPUT.PUT_LINE('1�ڴ� ����� �����߽��ϴ�!�����ڵ� : '||prm_code);
    DBMS_OUTPUT.PUT_LINE('����� ��� : '||pprice);
END ; -- Procedure UP_UPDPRICE��(��) �����ϵǾ����ϴ�.

[����] 
EXEC UP_UPDPRICE('RM17', 100000); 
EXEC UP_UPDPRICE('RM17', 200000); 

SELECT rm_code, price
FROM room
WHERE rm_code = 'RM17'; 

UPDATE room
SET price = 10000
WHERE price >= 800000; 
���� ��� : 801624

8) ȯ����å 
CREATE OR REPLACE PROCEDURE up_updRefpolicy
(
    prm_code room.rm_code%TYPE, 
    pref_policy room.ref_policy%TYPE
)
IS 
BEGIN 
    UPDATE room
        SET ref_policy = pref_policy
    WHERE rm_code = prm_code; 
    COMMIT; 
    
    DBMS_OUTPUT.PUT_LINE('ȯ����å�� �����߽��ϴ�!�����ڵ� : '||prm_code);
    DBMS_OUTPUT.PUT_LINE('����� ȯ����å : '||pref_policy);
END ; -- Procedure UP_UPDREFPOLICY��(��) �����ϵǾ����ϴ�.

[����] 
EXEC UP_UPDREFPOLICY('RM17', '����') ; 

SELECT * 
FROM room
WHERE rm_code = 'RM17'; 


9) ����� ��Ϲ�ȣ ��� 

CREATE OR REPLACE PROCEDURE up_updNumber
(
    prm_code room.rm_code%TYPE, 
    prm_number room.rm_number%TYPE
)
IS 
BEGIN 
    UPDATE room
        SET rm_number = prm_number
    WHERE rm_code = prm_code; 
    COMMIT; 
    
    DBMS_OUTPUT.PUT_LINE('����� ��Ϲ�ȣ�� ����߽��ϴ�! �����ڵ� : '||prm_code);
    DBMS_OUTPUT.PUT_LINE('����� ��Ϲ�ȣ : '||prm_number);
END ; -- Procedure UP_UPDNUMBER��(��) �����ϵǾ����ϴ�.

[����] 
EXEC UP_UPDNUMBER('RM42',5262617323); 

SELECT *
FROM room
WHERE rm_code = 'RM42'; 

10) üũ��, üũ�ƿ� �ð� ���� 
CREATE OR REPLACE PROCEDURE up_updRoomtime
(
    prm_code room.rm_code%TYPE, 
    pci_time room.ci_time%TYPE,
    pco_time room.ci_time%TYPE
)
IS 
    v_cannot_reserve_exception EXCEPTION; 
BEGIN 
    IF TO_NUMBER( SUBSTR(pci_time, 1, INSTR(pci_time, ':') - 1)) BETWEEN 1 AND 7 THEN 
        RAISE v_cannot_reserve_exception ;
    ELSE     
        UPDATE room
            SET ci_time = pci_time
        WHERE rm_code = prm_code; 
    END IF; 

    UPDATE room
    SET co_time = pco_time
    WHERE rm_code = prm_code; 
    COMMIT; 
    
    DBMS_OUTPUT.PUT_LINE('üũ��/ üũ�ƿ� �ð��� ����߽��ϴ�! �����ڵ� : '||prm_code);
    DBMS_OUTPUT.PUT_LINE('üũ�� �ð� : '||pci_time );
    DBMS_OUTPUT.PUT_LINE('üũ�ƿ� �ð� : '||pco_time );
    
EXCEPTION 
    WHEN v_cannot_reserve_exception THEN 
        RAISE_APPLICATION_ERROR(-20999,'���� 1��~7�ô� üũ�� �� �� �����ϴ�.') ; 
END ;--Procedure UP_UPDROOMTIME��(��) �����ϵǾ����ϴ�.

[����] 
EXEC UP_UPDROOMTIME('RM42', '15:00','13:00') 
EXEC UP_UPDROOMTIME('RM42', '2:00','13:00') 

SELECT rm_code, ci_time, co_time
FROM room
WHERE rm_code = 'RM42';

--------------------------------------------------------
    3. �߰����� �� ���� 
--------------------------------------------------------

1. ���ǽü� 
1) ���ǽü����� ���
CREATE OR REPLACE PROCEDURE up_insFac (
    prm_code room.rm_code%TYPE,
    pfa_code facility.fa_code%TYPE
)
IS
    vfaset_code facset.faset_code%TYPE; 
BEGIN 
    SELECT 'SEFA' || TO_CHAR( NVL( MAX( TO_NUMBER( SUBSTR( faset_code, 5 ) ) ), 0 ) + 1 )
    INTO vfaset_code
    FROM facset; 
    
    INSERT INTO facset( faset_code, fa_code, rm_code )
                 VALUES(  vfaset_code, pfa_code, prm_code );
END;    --Procedure UP_INSFAC��(��) �����ϵǾ����ϴ�.

[����] 
EXEC UP_INSFAC('RM17', 'FA8'); 

SELECT * 
FROM facset
WHERE rm_code = 'RM17'; 


2) ���ǽü����� ���� 
CREATE OR REPLACE PROCEDURE up_delFacSet
(
    prm_code ruleset.rm_code%TYPE,
    pfa_code facset.fa_code%TYPE
)
IS
    vfa_name facility.fa_name%TYPE;
BEGIN
    DELETE FROM facset
    WHERE fa_code = pfa_code
      AND rm_code = prm_code;
END; --Procedure UP_DELFACSET��(��) �����ϵǾ����ϴ�.

[����] 
EXEC UP_DELFACSET('RM17','FA8'); 

SELECT * 
FROM facset
WHERE rm_code = 'RM17'; 


2. �̿��Ģ 
1) �̿��Ģ ���� 
CREATE OR REPLACE PROCEDURE up_insRuleSet
(
    prule_code ruleset.rule_code%TYPE,
    prm_code ruleset.rm_code%TYPE,
    pmaxpet room.maxpet%TYPE
)
IS
    vruleset_code ruleset.ruleset_code%TYPE;
BEGIN
    SELECT 'RS' || TO_CHAR( NVL( MAX( TO_NUMBER( SUBSTR( ruleset_code, 3 ) ) ), 0 ) + 1 )
    INTO vruleset_code 
    FROM ruleset; 
    
    INSERT INTO ruleset( ruleset_code, rule_code, rm_code ) 
        VALUES( vruleset_code, prule_code, prm_code );
    
    IF prule_code = 'RU2' THEN
        UPDATE room
        SET maxpet = pmaxpet
        WHERE rm_code = prm_code;
        
    END IF;
    COMMIT;
END;

[����] 
EXEC up_insRuleSet( 'RU3', 'RM40', null );
EXEC up_insRuleSet( 'RU2', 'RM40', 5 );

SELECT *
FROM ruleset
WHERE rm_code = 'RM40'
ORDER BY ruleset_code;

SELECT rm_code, maxpet
FROM room
WHERE rm_code = 'RM40';

2) �̿��Ģ ���� 
CREATE OR REPLACE PROCEDURE up_delRuleSet
(
    prule_code ruleset.rule_code%TYPE,
    prm_code ruleset.rm_code%TYPE
)
IS
BEGIN
    DELETE FROM ruleset
    WHERE rule_code = prule_code
      AND rm_code = prm_code;
      
    IF prule_code = 'RU2' THEN
        UPDATE room
        SET maxpet = 0
        WHERE rm_code = prm_code;        
        
        DELETE FROM feeset
        WHERE fee_code = 'ET2'
          AND rm_code = prm_code;
    END IF;    
    COMMIT;
--EXCEPTION
END;

[����] 
EXEC up_delRuleSet( 'RU3', 'RM40' );
EXEC up_delRuleSet( 'RU2', 'RM40' );

SELECT *
FROM ruleset
WHERE rm_code = 'RM40'
ORDER BY ruleset_code;

SELECT *
FROM feeset;



3) ���μ��� 
CREATE OR REPLACE PROCEDURE up_insDcSet
(
    pdc_code dcset.dc_code%TYPE,
    prm_code dcset.rm_code%TYPE,
    prate dcset.rate%TYPE,
    pdc_basis dcset.dc_basis%TYPE
)
IS
    vdcset_code dcset.dcset_code%TYPE;
    v_notnull EXCEPTION;
BEGIN
    SELECT 'ADDC' || TO_CHAR( NVL( MAX( TO_NUMBER( SUBSTR( dcset_code, 5 ) ) ), 0 ) + 1 )
    INTO vdcset_code 
    FROM dcset; 
    
    INSERT INTO dcset( dcset_code, dc_code, rm_code, dc_basis, rate )
                 VALUES( vdcset_code, pdc_code, prm_code, pdc_basis, prate );
    
    IF pdc_code = 'DC1' THEN
        UPDATE dcset
        SET dc_basis = 7
        WHERE dc_code = pdc_code
          AND rm_code = prm_code;
    ELSIF pdc_code = 'DC2' THEN
        UPDATE dcset
        SET dc_basis = 30
        WHERE dc_code = pdc_code
          AND rm_code = prm_code;
    END IF;
    
    IF pdc_code IN ('DC3','DC4') AND pdc_basis IS NULL THEN
    RAISE v_notnull;
    END IF;
    COMMIT;
EXCEPTION
    WHEN v_notnull THEN 
        RAISE_APPLICATION_ERROR(-20013, '���α����� �ʼ��Է� ���Դϴ�');
        ROLLBACK;
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('��Ÿ ���� �߻�');
      ROLLBACK;
END;

[����] 
EXEC up_insDcSet( 'DC1', 'RM3', '10', null );
EXEC up_insDcSet( 'DC2', 'RM3', '20', null );
EXEC up_insDcSet( 'DC3', 'RM3', '30', 90 );
EXEC up_insDcSet( 'DC4', 'RM3', '40', 3 );
EXEC up_insDcSet( 'DC4', 'RM3', '50', null );

SELECT *
FROM dcset
WHERE rm_code = 'RM3'
ORDER BY dcset_code;


4) ���μ��� ���� & ����
CREATE OR REPLACE PROCEDURE up_updDcSet
(
    pdc_code dcset.dc_code%TYPE,
    prm_code dcset.rm_code%TYPE,
    prate dcset.rate%TYPE,
    pdc_basis dcset.dc_basis%TYPE
)
IS
BEGIN
    UPDATE dcset
    SET rate = NVL( prate, rate )
      , dc_basis = NVL( pdc_basis, dc_basis )
    WHERE dc_code = pdc_code
      AND rm_code = prm_code;
      
    IF prate = 0 THEN
        DELETE FROM dcset
        WHERE dc_code = pdc_code
          AND rm_code = prm_code;
    END IF;
    COMMIT;
END;

[����]
EXEC up_updDcSet( 'DC1', 'RM3', '15', null );
EXEC up_updDcSet( 'DC2', 'RM3', '0', null );
EXEC up_updDcSet( 'DC3', 'RM3', '35', 100 );
EXEC up_updDcSet( 'DC4', 'RM3', '45', null );

SELECT *
FROM dcset;


4. �߰���� 

1) �߰���� ���� 
CREATE OR REPLACE PROCEDURE up_insFeeSet
(
    pfee_code feeset.fee_code%TYPE,
    prm_code feeset.rm_code%TYPE,
    pfee_cost feeset.fee_cost%TYPE,
    pfee_basis feeset.fee_basis%TYPE
)
IS
    vfeeset_code feeset.feeset_code%TYPE;
    vcount NUMBER;
    vruleset_code ruleset.ruleset_code%TYPE;
BEGIN
    SELECT 'CHCT' || TO_CHAR( NVL( MAX( TO_NUMBER( SUBSTR( feeset_code, 5 ) ) ), 0 ) + 1 )
    INTO vfeeset_code 
    FROM feeset; 
    
    INSERT INTO feeset( feeset_code, fee_code, rm_code, fee_basis, fee_cost )
                 VALUES( vfeeset_code, pfee_code, prm_code, pfee_basis, pfee_cost );
    
    IF pfee_code IN ('ET2','ET3','ET4') AND pfee_basis IS NULL THEN
        UPDATE feeset
        SET fee_basis = 1
        WHERE fee_code = pfee_code
          AND rm_code = prm_code;
    END IF;    
    
    SELECT COUNT(*) INTO vcount
    FROM ruleset
    WHERE rule_code = 'RU2'
      AND rm_code = prm_code;    
                 
    IF pfee_code = 'ET2' AND vcount = 0 THEN
        SELECT 'RS' || TO_CHAR( NVL( MAX( TO_NUMBER( SUBSTR( ruleset_code, 3 ) ) ), 0 ) + 1 )
        INTO vruleset_code 
        FROM ruleset; 
        
        INSERT INTO ruleset( ruleset_code, rule_code, rm_code )
                     VALUES( vruleset_code, 'RU2', prm_code );
    END IF;
    COMMIT;
END;

[����] 
EXEC up_insFeeSet( 'ET1', 'RM23', 30000, null );
EXEC up_insFeeSet( 'ET2', 'RM23', 15000, null );
EXEC up_insFeeSet( 'ET3', 'RM23', 25000, 2 );
EXEC up_insFeeSet( 'ET4', 'RM23', 20000, null );

SELECT *
FROM feeset
WHERE rm_code = 'RM23';

SELECT *
FROM ruleset
WHERE rm_code = 'RM23';


2) �߰���� ���� 
CREATE OR REPLACE PROCEDURE up_updFeeSet
(
    pfee_code feeset.fee_code%TYPE,
    prm_code feeset.rm_code%TYPE,
    pfee_cost feeset.fee_cost%TYPE,
    pfee_basis feeset.fee_basis%TYPE
)
IS
BEGIN
    UPDATE feeset
    SET fee_cost = NVL( pfee_cost, fee_cost )
      , fee_basis = NVL( pfee_basis, fee_basis )
    WHERE fee_code = pfee_code
      AND rm_code = prm_code;
      
    IF pfee_cost = 0 THEN
        DELETE FROM feeset
        WHERE fee_code = pfee_code
          AND rm_code = prm_code;
    END IF;
    COMMIT;
END;                 

[����]              
EXEC up_updFeeSet( 'ET1', 'RM23', 0, null );
EXEC up_updFeeSet( 'ET2', 'RM23', 0, null );
EXEC up_updFeeSet( 'ET3', 'RM23', 20000, 4 );
EXEC up_updFeeSet( 'ET4', 'RM23', 25000, null );


SELECT *
FROM feeset;
                 
                 
    




--------------------------------------------------------------------------------
--1.���������� ���� ���Ұ˻�
CREATE OR REPLACE PROCEDURE up_roomMainPage
(
    prm_type room.rm_type%TYPE := NULL
)
IS
    vpath photo.path%TYPE;
    vrm_name room.rm_name%TYPE;
    vrm_loc room.rm_loc%TYPE;
    vprice VARCHAR2(100);
    vrm_code room.rm_code%TYPE;
    vrm_avg NUMBER;
    CURSOR rinfo_cursor IS (
                        SELECT path,rm_name,rm_loc,TRIM(TO_CHAR(price,'L999,999,999')),a.rm_code
                        FROM room a LEFT JOIN photo b ON a.rm_code = b.rm_code
                        WHERE rm_type = prm_type
    );
BEGIN
    OPEN rinfo_cursor;
        LOOP
            FETCH rinfo_cursor INTO vpath,vrm_name,vrm_loc,vprice,vrm_code;
            EXIT WHEN rinfo_cursor%NOTFOUND;
            vrm_avg:=uf_reviewavg(vrm_code);
            --������ �ִ� ��쿡�� ������ ��µǰ�,���� ��쿡�� ������ ��µ��� �ʴ´�.
            IF vrm_avg IS NOT NULL  THEN
                DBMS_OUTPUT.PUT_LINE('���� : '||vpath ||' / �����̸� : '||vrm_name
                                    ||' / ��ġ : '||vrm_loc||' / ��� : '||vprice||' /�� / ���� : '||vrm_avg);
                DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------------------');
            ELSE
                DBMS_OUTPUT.PUT_LINE('���� : '||vpath ||' / �����̸� : '||vrm_name||' / ��ġ : '||vrm_loc||' / ��� : '||vprice||' /��');
                DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------------------');
            END IF;
        END LOOP;
    CLOSE rinfo_cursor;
END;

EXEC up_roomMainPage('�غ��ٷξ�');
--------------------------------------------------------------------------------
--2.���ø���Ʈ ��ȸ
CREATE OR REPLACE PROCEDURE up_wishlist
(
    pmem_code member.mem_code%TYPE := NULL
)
IS
    vpath photo.path%TYPE;
    vrm_loctype VARCHAR(350);
    vrm_name room.rm_name%TYPE;
    vbed room.bed%TYPE;
    CURSOR wishlist_cursor IS (
                        SELECT rm_loc||'�� '||space,rm_name,bed
                        FROM wishlist w LEFT JOIN room r ON w.rm_code=r.rm_code
                        WHERE mem_code=pmem_code
    );
BEGIN
    OPEN wishlist_cursor;
        LOOP
            FETCH wishlist_cursor INTO vrm_loctype,vrm_name,vbed;
            EXIT WHEN wishlist_cursor%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('���� ��ġ,Ÿ�� : '||vrm_loctype
                                    ||' / ���� �̸� : '||vrm_name||' / ħ�� : '||vbed||'��');
            DBMS_OUTPUT.PUT_LINE('------------------------------------------------------');
        END LOOP;
    CLOSE wishlist_cursor;
END;

EXEC up_wishlist('ME33');

--------------------------------------------------------------------------------
--���ø���Ʈ SEQUENCE ����
CREATE SEQUENCE seq_wishlist
START WITH 15
NOCYCLE
NOCACHE;

--Ʈ���� (���ø���Ʈ�� �ϳ��� ȸ���� ���� ���Ҹ� ����� �� ����)
CREATE OR REPLACE TRIGGER ut_INSwishlistB
BEFORE INSERT ON wishlist
FOR EACH ROW
DECLARE
    vwishcount NUMBER(1);
    wishlist_exception EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO vwishcount
    FROM wishlist
    WHERE rm_code = :NEW.rm_code AND mem_code = :NEW.mem_code;
    
    IF vwishcount>=1 THEN
        RAISE wishlist_exception;
    END IF;
EXCEPTION
    WHEN wishlist_exception   THEN
        RAISE_APPLICATION_ERROR(-20051,'�̹� ���ø���Ʈ�� �ֽ��ϴ�.');
END;

--3.���ø���Ʈ �߰�
CREATE OR REPLACE PROCEDURE up_INSwishlist
(
    pmem_code wishlist.mem_code%TYPE := NULL
    ,prm_code wishlist.rm_code%TYPE := NULL
)
IS
    mem_code_null EXCEPTION;
    rm_code_null EXCEPTION;
BEGIN
    IF pmem_code IS NULL    THEN
        RAISE mem_code_null;
    ELSIF prm_code IS NULL  THEN
        RAISE rm_code_null;
    END IF;
    INSERT INTO wishlist
    VALUES ('WL'||seq_wishlist.NEXTVAL,pmem_code,prm_code);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('���ø���Ʈ�� �߰��Ǿ����ϴ�.');
EXCEPTION
    WHEN mem_code_null  THEN
        RAISE_APPLICATION_ERROR(-20051,'���ø���Ʈ �߰� �����ʾҽ��ϴ�. ����ڵ带 �Է����ּ���.');
    WHEN rm_code_null   THEN
        RAISE_APPLICATION_ERROR(-20052,'���ø���Ʈ �߰� �����ʾҽ��ϴ�. �����ڵ带 �Է����ּ���.');
END;

EXEC UP_INSWISHLIST('ME2','RM17');

--------------------------------------------------------------------------------
--4.���ø���Ʈ ����
CREATE OR REPLACE PROCEDURE up_DELwishlist
(
    pmem_code wishlist.mem_code%TYPE := NULL
    ,prm_code wishlist.rm_code%TYPE := NULL
)
IS
    mem_code_null EXCEPTION;
    rm_code_null EXCEPTION;
BEGIN
    IF pmem_code IS NULL    THEN
        RAISE mem_code_null;
    ELSIF prm_code IS NULL  THEN
        RAISE rm_code_null;
    END IF;
    
    DELETE FROM wishlist
    WHERE mem_code = pmem_code AND rm_code = prm_code;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('���ø���Ʈ�� �����Ǿ����ϴ�.');
EXCEPTION
    WHEN mem_code_null  THEN
        RAISE_APPLICATION_ERROR(-20061,'���ø���Ʈ ���� �����ʾҽ��ϴ�. ����ڵ带 �Է����ּ���.');
    WHEN rm_code_null   THEN
        RAISE_APPLICATION_ERROR(-20062,'���ø���Ʈ ���� �����ʾҽ��ϴ�. �����ڵ带 �Է����ּ���.');
END;

--------------------------------------------------------------------------------
--������ �ıⰳ�� ���ϴ� �Լ� : uf_reviewcount(�����ڵ�)
CREATE OR REPLACE FUNCTION uf_reviewcount
(
    prm_code reserve.rm_code%TYPE := NULL
)
RETURN NUMBER
IS
    vcount NUMBER;
    rm_code_null EXCEPTION;
BEGIN
    IF prm_code IS NULL THEN
        RAISE rm_code_null;
    END IF;
    SELECT COUNT(*) INTO vcount
    FROM REVIEW r JOIN RESERVE s ON r.rev_code=s.rev_code
    WHERE rm_code = prm_code;
    
    RETURN(vcount);
EXCEPTION
    WHEN rm_code_null   THEN
        RAISE_APPLICATION_ERROR(-20071,'�����ڵ带 �Է��� �ּ���.');
END;

--�ش������ �ı������� ���ϴ� �Լ� uf_reviewavg(�����ڵ�)
CREATE OR REPLACE FUNCTION uf_reviewavg
(
    prm_code reserve.rm_code%TYPE := NULL
)
RETURN NUMBER
IS
    vavg NUMBER(3,2);
    rm_code_null EXCEPTION;
BEGIN
    IF prm_code IS NULL THEN
        RAISE rm_code_null;
    END IF;
    --���� ���ϴ� ����
    SELECT ROUND((SUM(rev_clean)/COUNT(*)+SUM(rev_correct)/COUNT(*)+SUM(rev_contact)/COUNT(*)+SUM(rev_loc)/COUNT(*)+SUM(rev_ci)/COUNT(*)+SUM(rev_price)/COUNT(*))/6,2) INTO vavg
    FROM REVIEW r JOIN RESERVE s ON r.rev_code=s.rev_code
    WHERE rm_code = prm_code;
    RETURN(vavg);
EXCEPTION
    WHEN rm_code_null   THEN
        RAISE_APPLICATION_ERROR(-20081,'�����ڵ带 �Է��� �ּ���.');
END;

--5.�ı� ��ȸ
CREATE OR REPLACE PROCEDURE up_review
(
    prm_code room.rm_code%TYPE := NULL
)
IS
    vmem_name member.mem_name%TYPE;
    vrev_date VARCHAR2(20);
    vcontent review.content%TYPE;
    vclean NUMBER(2,1);
    vcorrect NUMBER(2,1);
    vcontact NUMBER(2,1);
    vloc NUMBER(2,1);
    vci NUMBER(2,1);
    vprice NUMBER(2,1);
    vtotavg NUMBER(3,2);
    vrevcount NUMBER;
    vrm_code room.rm_code%TYPE;
    rm_code_null EXCEPTION;    
    CURSOR review_cursor IS 
        SELECT mem_name,TO_CHAR(rev_date,'YYYY"��" MM"��"'),content
        FROM review r JOIN reserve s ON r.rev_code = s.rev_code
                     JOIN member m ON s.mem_code = m.mem_code
        WHERE rm_code = prm_code
        ORDER BY rev_date DESC;
    
BEGIN
    IF prm_code IS NULL THEN
        RAISE rm_code_null;
    END IF;
    --�� �׸� �������
    SELECT AVG(rev_clean),AVG(rev_correct),AVG(rev_contact),AVG(rev_loc),AVG(rev_ci),AVG(rev_price)
    INTO vclean,vcorrect,vcontact,vloc,vci,vprice
    FROM review r JOIN reserve s ON r.rev_code=s.rev_code
    WHERE rm_code = prm_code;
    
    --������,�ıⰳ�� ���ϴ� �Լ����
    vtotavg := uf_reviewavg(prm_code);
    vrevcount := uf_reviewcount(prm_code);
    
    DBMS_OUTPUT.PUT_LINE('�� '||vtotavg||' �ı� '||vrevcount||' ��');
    DBMS_OUTPUT.PUT_LINE('û�ᵵ : '||vclean);
    DBMS_OUTPUT.PUT_LINE('��Ȯ�� : '||vcorrect);
    DBMS_OUTPUT.PUT_LINE('�ǼҼ��� : '||vcontact);
    DBMS_OUTPUT.PUT_LINE('��ġ : '||vloc);
    DBMS_OUTPUT.PUT_LINE('üũ�� : '||vci);
    DBMS_OUTPUT.PUT_LINE('���� ��� ���� : '||vprice);
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------');
    
    OPEN review_cursor;
        LOOP
            FETCH review_cursor INTO vmem_name,vrev_date,vcontent;
            --�ıⰡ 6��������µȴ�
            EXIT WHEN review_cursor%NOTFOUND OR review_cursor%ROWCOUNT>6;
            DBMS_OUTPUT.PUT_LINE('ȸ�� �̸� : '||vmem_name);
            DBMS_OUTPUT.PUT_LINE('��¥ : '||vrev_date);
            DBMS_OUTPUT.PUT_LINE('���� ���� : '||vcontent);
            DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
        END LOOP;
    CLOSE review_cursor;
EXCEPTION
    WHEN rm_code_null   THEN
        RAISE_APPLICATION_ERROR(-20091,'�����ڵ带 �Է��� �ּ���.');
END;

EXEC up_review('RM17');

--------------------------------------------------------------------------------
--�ı� SEQUENCE ����
CREATE SEQUENCE seq_review
START WITH 28
NOCYCLE
NOCACHE;

--Ʈ���� (�ı��ۼ��� �Ϸ�� ���ุ �����ϰ� �ϳ��� �����ϴ�.)
CREATE  OR REPLACE TRIGGER ut_INSreviewA
BEFORE INSERT ON review
FOR EACH ROW
DECLARE
    res_status_cancel EXCEPTION;
    res_status_notyet EXCEPTION;
    revcount_exception EXCEPTION;
    vres_status reserve.res_status%TYPE;
    revcount NUMBER(1);
BEGIN
    SELECT COUNT(*) INTO revcount
    FROM review v JOIN reserve s ON v.rev_code = s.rev_code
    WHERE v.rev_code = :NEW.rev_code;

    SELECT res_status INTO vres_status
    FROM review v JOIN reserve s ON v.rev_code=s.rev_code
    WHERE v.rev_code = :NEW.rev_code;
    
    IF vres_status = '��ҵ� ����' THEN
        RAISE res_status_cancel;
    ELSIF vres_status = '������ ����'    THEN
        RAISE res_status_notyet;
    ELSIF revcount =1  THEN
        RAISE revcount_exception;
    END IF;
EXCEPTION
    WHEN res_status_cancel   THEN
        RAISE_APPLICATION_ERROR(-20041,'��ҵ� ���� �̹Ƿ� �ı⸦ �ۼ��� �� �����ϴ�.');
    WHEN res_status_notyet   THEN
        RAISE_APPLICATION_ERROR(-20042,'���� �ϱ� �� �̹Ƿ� �ı⸦ �ۼ��� �� �����ϴ�.');
    WHEN revcount_exception   THEN
        RAISE_APPLICATION_ERROR(-20043,'�̹� �ı⸦ �ۼ��ϼ̽��ϴ�.');
END;

--6.�ı� �߰�
CREATE OR REPLACE PROCEDURE up_INSreview
(
    pcontent review.content%TYPE := NULL
    ,prev_clean review.rev_clean%TYPE := NULL
    ,prev_correct review.rev_correct%TYPE := NULL
    ,prev_contact review.rev_contact%TYPE := NULL
    ,prev_loc review.rev_loc%TYPE := NULL
    ,prev_ci review.rev_ci%TYPE := NULL
    ,prev_price review.rev_price%TYPE := NULL
    ,pres_code reserve.res_code%TYPE :=NULL
)
IS
    rev_clean_null EXCEPTION;
    rev_correct_null EXCEPTION;
    rev_contact_null EXCEPTION;
    rev_loc_null EXCEPTION;
    rev_ci_null EXCEPTION;
    rev_price_null EXCEPTION;
BEGIN
    INSERT INTO review
    VALUES('RE'||seq_review.NEXTVAL,pcontent,SYSDATE,prev_clean,prev_correct,prev_contact,prev_loc,prev_ci,prev_price);
    UPDATE reserve
    SET rev_code = 'RE'||seq_review.CURRVAL
    WHERE res_code = pres_code;
    COMMIT; 
    DBMS_OUTPUT.PUT_LINE('���䰡 �߰� �Ǿ����ϴ�.');
EXCEPTION
    WHEN rev_clean_null   THEN
        RAISE_APPLICATION_ERROR(-20101,'û�ᵵ ������ �Էµ��� �ʾҽ��ϴ�.');
    WHEN rev_correct_null   THEN
        RAISE_APPLICATION_ERROR(-20102,'��Ȯ�� ������ �Էµ��� �ʾҽ��ϴ�.');
    WHEN rev_contact_null   THEN
        RAISE_APPLICATION_ERROR(-20103,'�ǻ���� ������ �Էµ��� �ʾҽ��ϴ�.');
    WHEN rev_loc_null   THEN
        RAISE_APPLICATION_ERROR(-20104,'��ġ ������ �Էµ��� �ʾҽ��ϴ�.');    
    WHEN rev_ci_null   THEN
        RAISE_APPLICATION_ERROR(-20105,'üũ�� ������ �Էµ��� �ʾҽ��ϴ�.');   
    WHEN rev_price_null   THEN
        RAISE_APPLICATION_ERROR(-20106,'���ݴ������ ������ �Էµ��� �ʾҽ��ϴ�.');   
END;



--------------------------------------------------------------------------------
--7.�ı� ����
CREATE OR REPLACE PROCEDURE up_UDTreview
(
    prev_code review.rev_code%TYPE
    ,pcontent review.content%TYPE
    ,prev_clean review.rev_clean%TYPE
    ,prev_correct review.rev_correct%TYPE
    ,prev_contact review.rev_contact%TYPE
    ,prev_loc review.rev_loc%TYPE
    ,prev_ci review.rev_ci%TYPE
    ,prev_price review.rev_price%TYPE
)
IS
    rev_code_null EXCEPTION;
    vcontent review.content%TYPE;
    vrev_clean review.rev_clean%TYPE;
    vrev_correct review.rev_correct%TYPE;
    vrev_contact review.rev_contact%TYPE;
    vrev_loc review.rev_loc%TYPE;
    vrev_ci review.rev_ci%TYPE;
    vrev_price review.rev_price%TYPE;
BEGIN
    SELECT content,rev_clean,rev_correct,rev_contact,rev_loc,rev_ci,rev_price
    INTO vcontent,vrev_clean,vrev_correct,vrev_contact,vrev_loc,vrev_ci,vrev_price
    FROM review
    WHERE rev_code = prev_code;
    --�׸� ������ �����ϸ� �����Ѱ����� , �׷��������� ������ �� �״�� UPDATE
    UPDATE review
    SET 
    content=NVL(pcontent,vcontent)
    ,rev_date = SYSDATE
    ,rev_clean=NVL(prev_clean,vrev_clean)
    ,rev_correct=NVL(prev_correct,vrev_correct)
    ,rev_contact=NVL(prev_contact,vrev_contact)
    ,rev_loc=NVL(prev_loc,vrev_loc)
    ,rev_ci=NVL(prev_ci,vrev_ci)
    ,rev_price=NVL(prev_price,vrev_price)
    WHERE rev_code = prev_code;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('���䰡 ���� �Ǿ����ϴ�.');
END;

--------------------------------------------------------------------------------
--Ʈ���� (�ıⰡ �����Ǳ��� �������̺� �ı��ڵ� null�� ����)
CREATE OR REPLACE TRIGGER ut_DELreviewB
BEFORE DELETE ON review
FOR EACH ROW
BEGIN
    UPDATE reserve
    SET rev_code = NULL
    WHERE rev_code = :OLD.rev_code;
END;

--8.�ı� ����
CREATE OR REPLACE PROCEDURE up_DELreview
(
    prev_code review.rev_code%TYPE := NULL
)
IS
    rev_code_null EXCEPTION;
BEGIN
    IF prev_code IS NULL THEN
        RAISE rev_code_null;
    END IF;
    DELETE FROM review
    WHERE rev_code = prev_code;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('�ıⰡ ���� �Ǿ����ϴ�.');
EXCEPTION
    WHEN rev_code_null   THEN
    DBMS_OUTPUT.PUT_LINE('�ı��ڵ带 �Է����ּ���.');
END;

--------------------------------------------------------------------------------
--9.���� ���ǽü� ��ȸ
CREATE OR REPLACE PROCEDURE up_facility
(
    prm_code room.rm_code%TYPE := NULL
)
IS
    vfa_type FACDEVIDE.fa_type%TYPE;
    vfa_name FACILITY.fa_name%TYPE;
    CURSOR facility_cursor IS (
                                SELECT fa_type,fa_name
                                FROM FACSET a JOIN FACILITY b ON a.fa_code=b.fa_code
                                                JOIN FACDEVIDE c ON c.fadev_code= b.fadev_code
                                WHERE rm_code = prm_code
    );
    rm_code_null EXCEPTION;
BEGIN
    IF prm_code IS NULL THEN
        RAISE rm_code_null;
    END IF;
    
    OPEN facility_cursor;
        LOOP
            FETCH facility_cursor INTO vfa_type,vfa_name;
            EXIT WHEN facility_cursor%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('���ǽü� ���� : '||vfa_type);
            DBMS_OUTPUT.PUT_LINE('���ǽü� �̸� : '||vfa_name);
        END LOOP;
    CLOSE facility_cursor;
EXCEPTION
    WHEN rm_code_null   THEN
        RAISE_APPLICATION_ERROR(-20111,'�����ڵ带 �Է����ּ���');
END;

EXEC up_facility('RM17');

--------------------------------------------------------------------------------
--10.���� �̿��Ģ ��ȸ
CREATE OR REPLACE PROCEDURE up_ruleset
(
    prm_code room.rm_code%TYPE := NULL
)
IS
    vmaxguest room.maxguest%TYPE;
    vmaxpet room.maxpet%TYPE;
    vci_time room.ci_time%TYPE;
    vco_time room.co_time%TYPE;
    vrule_type rule.rule_type%TYPE;
    vcanpet VARCHAR2(10);
    CURSOR rr_cursor IS (
                                SELECT maxguest,maxpet,ci_time,co_time,rule_type
                                FROM room r JOIN ruleset s ON r.rm_code=s.rm_code
                                            JOIN rule u ON s.rule_code=u.rule_code
                                WHERE r.rm_code = prm_code
    );
    rm_code_null EXCEPTION;
BEGIN
    IF prm_code IS NULL THEN
        RAISE rm_code_null;
    END IF;
    
    OPEN rr_cursor;
        LOOP
            FETCH rr_cursor INTO vmaxguest,vmaxpet,vci_time,vco_time,vrule_type;
            EXIT WHEN rr_cursor%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('�Խ�Ʈ ���� ');
            DBMS_OUTPUT.PUT_LINE('�Խ�Ʈ ���� : '||vmaxguest);
            IF vmaxpet IS NULL OR vmaxpet=0 THEN
                vcanpet := '����';
            ELSE 
                vcanpet := '�Ұ���';
            END IF;
            DBMS_OUTPUT.PUT_LINE('�ݷ����� ���� '||vcanpet);
            DBMS_OUTPUT.PUT_LINE('üũ�� ���� �ð� : '||vci_time);
            DBMS_OUTPUT.PUT_LINE('üũ�� ���� �ð� : '||vco_time);
            DBMS_OUTPUT.PUT_LINE(vrule_type);  
        END LOOP;
    CLOSE rr_cursor;
END;

EXEC up_ruleset('RM17');

--------------------------------------------------------------------------------
--���� SEQUENCE ����
CREATE SEQUENCE seq_pay
START WITH 21
NOCYCLE
NOCACHE;

--Ʈ���� (������°� '������ ����'�� �ƴϸ� ������ �� �� �ִ�)
CREATE OR REPLACE TRIGGER ut_INSUDTpayB
BEFORE INSERT OR UPDATE ON pay
FOR EACH ROW
DECLARE
    vres_status reserve.res_status%TYPE;
    res_status_already_exception    EXCEPTION;
    res_status_cancel_exception EXCEPTION;
BEGIN
    SELECT res_status   INTO vres_status
    FROM reserve
    WHERE res_code = :NEW.res_code;
    
    IF vres_status = '�Ϸ�� ����'  THEN
        RAISE res_status_already_exception;
    ELSIF vres_status = '�Ϸ�� ����'  THEN
        RAISE res_status_cancel_exception;
    END IF;
EXCEPTION
    WHEN res_status_already_exception   THEN
        RAISE_APPLICATION_ERROR(-20031,'�Ϸ�� �����̱� ������ ������ �Ұ��� �մϴ�.');
    WHEN res_status_cancel_exception   THEN
        RAISE_APPLICATION_ERROR(-20032,'��ҵ� �����̱� ������ ������ �Ұ��� �մϴ�.');
END;

--Ʈ���� (������ ������ �� ����, ���� �Ŀ��� ��Ұ� �ƴ� ȯ���̱� ������)
CREATE OR REPLACE TRIGGER ut_DELpayB
BEFORE DELETE ON pay
FOR EACH ROW
DECLARE
    vcant NUMBER(1);
    vcant_cancel_exception EXCEPTION;
BEGIN
    vcant := 1;
    IF vcant =1 THEN
        RAISE vcant_cancel_exception;
    END IF;
EXCEPTION
    WHEN vcant_cancel_exception   THEN
        RAISE_APPLICATION_ERROR(-20041,'���� ��Ҵ� ȯ���� �̿��� �ּ���.');
END;

--11.���� �߰�
CREATE OR REPLACE PROCEDURE up_INSpay
(
    ppay_country pay.pay_country%TYPE :=NULL
    ,pcardnum pay.cardnum%TYPE :=NULL
    ,pexpiredate pay.expiredate%TYPE :=NULL
    ,pcvc pay.cvc%TYPE :=NULL
    ,ppostcode pay.postcode%TYPE :=NULL
    ,pres_code pay.res_code%TYPE :=NULL
    ,pmem_code pay.mem_code%TYPE :=NULL
)
IS
    vpay_country pay.pay_country%TYPE;
BEGIN
    vpay_country := NVL(ppay_country,'�ѱ�');
    INSERT INTO pay
    VALUES('PA'||seq_pay.NEXTVAL,ppay_country,SYSDATE,pcardnum,pexpiredate,pcvc,ppostcode,pres_code,pmem_code);
    COMMIT;
END;

select *
from pay;

--------------------------------------------------------------------------------
--12.���� ���� ��ȸ
CREATE OR REPLACE PROCEDURE up_pay
(
    ppay_code pay.res_code%TYPE
)
IS
    vres_code reserve.res_code%TYPE;
    vrm_name room.rm_name%TYPE;
    vmem_name member.mem_name%TYPE;
    vpay_date pay.pay_date%TYPE;
    vcardnum VARCHAR2(30);
    vexpiredate pay.expiredate%TYPE;
    vpostcode pay.postcode%TYPE;
    vtot_cost reserve.tot_cost%TYPE;
    CURSOR payinfo_cursor IS(
                                SELECT r.res_code,rm_name,mem_name,pay_date,RPAD(SUBSTR(cardnum,1,6),LENGTH(cardnum)+1,'*'),expiredate,postcode,tot_cost
                                FROM pay p JOIN member m ON p.mem_code = m.mem_code
                                            JOIN reserve r ON p.res_code = r.res_code
                                            JOIN room o ON r.rm_code=o.rm_code
                                WHERE pay_code = ppay_code
                                );
BEGIN
    OPEN payinfo_cursor;
    LOOP
        FETCH payinfo_cursor INTO vres_code,vrm_name,vmem_name,vpay_date,vcardnum,vexpiredate,vpostcode,vtot_cost;
        EXIT WHEN payinfo_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('���� �ڵ� : '||vres_code);
        DBMS_OUTPUT.PUT_LINE('���� �̸� : '||vrm_name);
        DBMS_OUTPUT.PUT_LINE('������ �̸� : '||vmem_name);
        DBMS_OUTPUT.PUT_LINE('���� ��¥ : '||vpay_date);
        DBMS_OUTPUT.PUT_LINE('ī���ȣ : '||vcardnum);
        DBMS_OUTPUT.PUT_LINE('���� ��¥ : '||vexpiredate);
        DBMS_OUTPUT.PUT_LINE('���� ��ȣ : '||vpostcode);
        DBMS_OUTPUT.PUT_LINE('���� �ݾ� : '||vtot_cost);
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    END LOOP;
    CLOSE payinfo_cursor;
END;

EXEC up_pay('PA1');

--------------------------------------------------------------------------------
--13.���� ���� ��ȸ
CREATE OR REPLACE PROCEDURE up_reserve
(
    pres_code reserve.mem_code%TYPE
)
IS
    vrm_name room.rm_name%TYPE;
    vci_date VARCHAR2(30);
    vci_time room.ci_time%TYPE;
    vco_date VARCHAR2(30);
    vco_time room.co_time%TYPE;
    vrm_loc room.rm_loc%TYPE;
    vmem_name member.mem_name%TYPE;
    vrm_loc2 room.rm_loc%TYPE;
    CURSOR reserveinfo_cursor IS (
                                    SELECT rm_name,TO_CHAR(ci_date,'MM"��"DD"��"(DY)'),ci_time,TO_CHAR(co_date,'MM"��"DD"��"(DY)'),co_time,rm_loc,mem_name,rm_loc
                                    FROM reserve r JOIN room m ON r.rm_code=m.rm_code
                                                    JOIN register g ON m.rm_code=g.rm_code
                                                    JOIN member b ON g.mem_code=b.mem_code
                                    WHERE res_code = pres_code
                                    );
BEGIN
    OPEN reserveinfo_cursor;
    LOOP
        FETCH reserveinfo_cursor INTO vrm_name,vci_date,vci_time,vco_date,vco_time,vrm_loc,vmem_name,vrm_loc2;
        EXIT WHEN reserveinfo_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(vrm_name||' ���� ������ �Ϸ�Ǿ����ϴ�.');
        DBMS_OUTPUT.PUT_LINE('üũ�� : '||vci_date||' '||vci_time);
        DBMS_OUTPUT.PUT_LINE('üũ�ƿ� : '||vco_date||' '||vco_time);
        DBMS_OUTPUT.PUT_LINE('ã�ư��� ��� : '||vrm_loc);
        DBMS_OUTPUT.PUT_LINE('ã�ư��� ��� : �ȳ� �� ���� �̿��Ģ');
        DBMS_OUTPUT.PUT_LINE('ȣ��Ʈ���� �޽��� ������ : '||vmem_name);
        DBMS_OUTPUT.PUT_LINE('���� : '||vrm_loc2);
        
    END LOOP;
    CLOSE reserveinfo_cursor;
END;

EXEC UP_RESERVE('RS1');

--------------------------------------------------------------------------------
--13-2.���� �������� ��ȸ
CREATE OR REPLACE PROCEDURE up_detailreserve
(
    pres_code reserve.res_code%TYPE
)
IS
    vhuman NUMBER(3);
    vres_code reserve.res_code%TYPE;
    vref_policy room.ref_policy%TYPE;
    CURSOR detailreserve_cursor IS(
                                    SELECT adult+child+infant,res_code,ref_policy
                                    FROM reserve r JOIN room m ON r.rm_code = m.rm_code
                                    WHERE res_code = pres_code
                                    );
BEGIN
    OPEN detailreserve_cursor;
    LOOP
        FETCH detailreserve_cursor INTO vhuman,vres_code,vref_policy;
        EXIT WHEN detailreserve_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('�Խ�Ʈ : '||vhuman||'��');
        DBMS_OUTPUT.PUT_LINE('���� ��ȣ : '||vres_code);
        DBMS_OUTPUT.PUT_LINE('ȯ�� ��å : '||vref_policy);
    END LOOP;
    CLOSE detailreserve_cursor;
END;

EXEC UP_DETAILRESERVE('RS1');

--------------------------------------------------------------------------------
--���� SEQUENCE ����
CREATE SEQUENCE seq_reserve
START WITH 53
NOCYCLE
NOCACHE;

--Ʈ����(������ ������ ���� ������ ������ �����ϸ� ���ο��� �ִ��ο��� ������ ���� �ݷ������� �ִ�ݷ������� ���� �� ����) 
CREATE OR REPLACE TRIGGER ut_INSUDTreserveB
BEFORE INSERT OR UPDATE ON reserve
FOR EACH ROW
DECLARE
    CURSOR insreserve_cursor IS(
                                SELECT ci_date,co_date
                                FROM reserve
                                WHERE res_status = '������ ����' AND rm_code = :NEW.rm_code
                                );
    date_exception EXCEPTION;
    all_human_exception EXCEPTION;
    all_pet_exception EXCEPTION;
    vci_date reserve.ci_date%TYPE;
    vco_date reserve.co_date%TYPE;
    vci reserve.co_date%TYPE;
    vco reserve.co_date%TYPE;
    vmaxguest room.maxguest%TYPE;
    vmaxpet room.maxpet%TYPE;
    
BEGIN
    SELECT maxguest,maxpet INTO vmaxguest,vmaxpet
    FROM room
    WHERE rm_code = :NEW.rm_code; 
    IF vmaxguest < (:NEW.adult + :NEW.child) THEN
        RAISE all_human_exception;
    ELSIF vmaxpet < :NEW.pet  THEN
        RAISE all_pet_exception;
    END IF;
    --�����Ϸ��� ��¥�� �ߺ���¥�� �ִ��� Ȯ��
    OPEN insreserve_cursor;
    LOOP
        FETCH insreserve_cursor INTO vci_date,vco_date;
        EXIT WHEN insreserve_cursor%NOTFOUND;
        IF :NEW.ci_date BETWEEN vci_date AND vco_date-1 THEN
            RAISE date_exception;
        ELSIF :NEW.co_date BETWEEN vci_date-1 AND vco_date  THEN
            RAISE date_exception;
        END IF;
    END LOOP;
    CLOSE insreserve_cursor;
EXCEPTION
    WHEN date_exception   THEN
        RAISE_APPLICATION_ERROR(-20121,'�ش糯¥�� �̹� ������ �ֽ��ϴ�.');
    WHEN all_human_exception   THEN
        RAISE_APPLICATION_ERROR(-20122,'�ο��� �ִ�����ο��� �ʰ��߽��ϴ�.');
    WHEN all_pet_exception   THEN
        RAISE_APPLICATION_ERROR(-20123,'�ݷ������� �ִ����ݷ������� �ʰ��߽��ϴ�.');
END;

--------------------------------------------------------------------------------
--14.ȯ�� ���� ��ȸ
CREATE OR REPLACE PROCEDURE up_refund
(
    pres_code reserve.res_code%TYPE := NULL
)
IS
    vci VARCHAR2(100);
    vco VARCHAR2(100);
    vspace room.space%TYPE;
    vbed room.bed%TYPE;
    vperson NUMBER(3);
    vmem_name member.mem_name%TYPE;
    vrm_name room.rm_name%TYPE;
    vref_policy room.ref_policy%TYPE;
    vres_status reserve.res_status%TYPE;
    vref_cost refund.ref_cost%TYPE;
    vtot_cost reserve.tot_cost%TYPE;
    vcardnum pay.cardnum%TYPE;
    vdate VARCHAR2(100);
    valldays NUMBER(3);
    CURSOR payinfo_cursor IS(
                                SELECT TO_CHAR(ci_date,'YYYY"��"MM"��"DD"��"(DY)') ,TO_CHAR(co_date,'YYYY"��"MM"��"DD"��"(DY)')
                                ,space,bed,adult+child,mem_name,m.rm_name,ref_policy,res_status,ref_cost,tot_cost
                                ,cardnum,TO_CHAR(sysdate,'YYYY MM DD HH:MI:SS'),co_date-ci_date
                                FROM refund f JOIN reserve r ON f.res_code=r.res_code
                                        JOIN room m ON r.rm_code = m.rm_code
                                        JOIN register g ON m.rm_code = g.rm_code
                                        JOIN member b ON g.mem_code = b.mem_code
                                        JOIN pay p ON r.res_code=p.res_code
                                WHERE r.res_code = pres_code
                                );
BEGIN
    OPEN payinfo_cursor;
    LOOP
        FETCH payinfo_cursor 
        INTO vci,vco,vspace,vbed,vperson,vmem_name,vrm_name,vref_policy,vres_status,vref_cost,vtot_cost,vcardnum,vdate,valldays;
        EXIT WHEN payinfo_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(vrm_name||'���� '||valldays||'��');
        DBMS_OUTPUT.PUT_LINE(vci||' -> '||vco);
        DBMS_OUTPUT.PUT_LINE(vspace||', ħ�� '||vbed||'�� , �Խ�Ʈ '||vperson||'��');
        DBMS_OUTPUT.PUT_LINE('ȣ��Ʈ : '||vmem_name);
        DBMS_OUTPUT.PUT_LINE('Ȯ�� �ڵ�(���� �ڵ�) : '||pres_code);
        DBMS_OUTPUT.PUT_LINE('ȯ�� ��å : '||vref_policy);
        DBMS_OUTPUT.PUT_LINE('-------------------------');
        DBMS_OUTPUT.PUT_LINE('��ݳ���');
        DBMS_OUTPUT.PUT_LINE('���� ���� : '||vres_status);
        DBMS_OUTPUT.PUT_LINE('�Ѱ��� �ݾ� : '||vtot_cost);
        DBMS_OUTPUT.PUT_LINE('ȯ�ұݾ� : '||vref_cost);
        DBMS_OUTPUT.PUT_LINE('-------------------------');
        DBMS_OUTPUT.PUT_LINE('ī�� ��ȣ : '||vcardnum);
    END LOOP;
    CLOSE payinfo_cursor;
END;

EXEC up_refund('RS4');

--------------------------------------------------------------------------------
--ȯ�� SEQUENCE ����
CREATE SEQUENCE seq_refund
START WITH 6
NOCYCLE
NOCACHE;

--Ʈ���� (ȯ���� ���������� �����ȣ�� �־�� ȯ���� �����ϴ�.)
CREATE OR REPLACE TRIGGER ut_INSrefundB
BEFORE INSERT ON refund
FOR EACH ROW
DECLARE
    vpay NUMBER(1);
    refund_cannot_exception EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO vpay
    FROM pay
    WHERE res_code = :NEW.res_code;
    
    IF vpay=0   THEN
        RAISE refund_cannot_exception;
    END IF;
EXCEPTION    
    WHEN refund_cannot_exception    THEN
        RAISE_APPLICATION_ERROR(-20021,'������ �����ʾ����Ƿ� ȯ���� �Ұ��� �մϴ�.');
END;

--�����ȣ�� �޾� ȯ�ұݾ� ����ϴ� �Լ� uf_refundCost(�����ȣ)
CREATE OR REPLACE FUNCTION uf_refundCost
(
    pres_code refund.res_code%TYPE
)
RETURN NUMBER
IS
    vref_policy room.ref_policy%TYPE;
    vtot_cost reserve.tot_cost%TYPE;
    vref_cost refund.ref_cost%TYPE;
    vci reserve.ci_date%TYPE;
    vres_date reserve.res_date%TYPE;
    vtoday  date;
    ref_policy_exception EXCEPTION;
    vrequestdate refund.requestdate%TYPE;
BEGIN
    SELECT ref_policy,tot_cost,ci_date,TRUNC(SYSDATE,'DD'),res_date,requestdate
    INTO vref_policy,vtot_cost,vci,vtoday,vres_date,vrequestdate
    FROM reserve v JOIN room r ON v.rm_code=r.rm_code
                    JOIN refund f ON v.res_code=f.res_code
    WHERE v.res_code=pres_code;
    
    IF vref_policy = '����' THEN
        IF vci-vrequestdate >=1    THEN
            vref_cost := vtot_cost;
        ELSE
            vref_cost := 0;
        END IF;
    ELSIF vref_policy = '�Ϲ�'  THEN
        IF vci-vrequestdate >=5 THEN
            vref_cost := vtot_cost;
        ELSIF vci-vrequestdate BETWEEN 1 AND 4 THEN
            vref_cost := vtot_cost*0.5;
        ELSE
            vref_cost := 0;
        END IF;
    ELSIF vref_policy = '��������'  THEN
        IF vci-vrequestdate >=30 THEN
            vref_cost := vtot_cost;
        ELSIF vrequestdate-vres_date<2 AND vci-vrequestdate >=14    THEN
            vref_cost := vtot_cost;
        ELSIF vci-vrequestdate BETWEEN 7 AND 30  THEN
            vref_cost := vtot_cost*0.5;
        ELSE
            vref_cost := 0;
        END IF;
    ELSIF vref_policy = '����'  THEN
        IF vrequestdate-vres_date<2 AND vci-vrequestdate >=14    THEN
            vref_cost := vtot_cost;
        ELSIF vci-vrequestdate BETWEEN 7 AND 30  THEN
            vref_cost := vtot_cost*0.5;
        ELSE
            vref_cost := 0;
        END IF;
    ELSIF vref_policy = '�ſ����30��'  THEN
        IF vci-vrequestdate >= 30 THEN
            vref_cost := vtot_cost*0.5;
        ELSE
            vref_cost := 0;
        END IF;
    ELSIF vref_policy = '�ſ����60��'  THEN
        IF vci-vrequestdate >= 60 THEN
            vref_cost := vtot_cost*0.5;
        ELSE
            vref_cost := 0;
        END IF;
    ELSE
        RAISE ref_policy_exception;
    END IF;
    RETURN(vref_cost);
EXCEPTION
    WHEN ref_policy_exception   THEN
        RAISE_APPLICATION_ERROR(-20001,'������ ȯ����å�� �� �� �Ǿ��ֽ��ϴ�.');
END;

--15.ȯ�� �߰�
CREATE OR REPLACE PROCEDURE up_INSrefund
(
    pref_reason refund.ref_reason%TYPE :=NULL
    ,prm_code refund.rm_code%TYPE :=NULL
    ,pres_code refund.res_code%TYPE :=NULL
)
IS
    ref_reason_exception EXCEPTION;
    rm_code_exception EXCEPTION;
    res_code_exception EXCEPTION;
BEGIN
    IF pref_reason IS NULL  THEN
        RAISE ref_reason_exception;
    ELSIF prm_code IS NULL  THEN
        RAISE rm_code_exception;
    ELSIF pres_code IS NULL THEN
        RAISE res_code_exception;
    END IF;
    
    INSERT INTO refund
    VALUES('RF'||seq_refund.NEXTVAL,pref_reason,uf_refundCost(pres_code),SYSDATE,prm_code,pres_code);
    COMMIT;
EXCEPTION
    WHEN ref_reason_exception   THEN
        RAISE_APPLICATION_ERROR(-20011,'ȯ�� ������ �Է��� �ּ���.');
    WHEN rm_code_exception   THEN
        RAISE_APPLICATION_ERROR(-20012,'�����ڵ带 �Է��� �ּ���.');
    WHEN res_code_exception   THEN
        RAISE_APPLICATION_ERROR(-20013,'�����ڵ带 �Է��� �ּ���.');
END;

--Ʈ���� (ȯ���� �߰��� �ڿ��� ������ ������°� ����� �������� ����Ǿ�� �Ѵ�)
CREATE OR REPLACE TRIGGER ut_INSrefundA
AFTER INSERT ON refund
FOR EACH ROW
BEGIN
    UPDATE reserve
    SET res_status = '��ҵ� ����'
    WHERE res_code=:NEW.res_code;
END;

--------------------------------------------------------------------------------
-- ���� �� üũ �ڵ�
CREATE OR REPLACE TRIGGER ut_INSUDTreserveB
BEFORE INSERT OR UPDATE ON reserve
FOR EACH ROW
DECLARE
    CURSOR insreserve_cursor IS(
                                SELECT ci_date,co_date
                                FROM reserve
                                WHERE res_status = '������ ����' AND rm_code = :NEW.rm_code
                                );
    date_exception EXCEPTION;
    all_human_exception EXCEPTION;
    all_pet_exception EXCEPTION;
    vci_date reserve.ci_date%TYPE;
    vco_date reserve.co_date%TYPE;
    vci reserve.co_date%TYPE;
    vco reserve.co_date%TYPE;
    vmaxguest room.maxguest%TYPE;
    vmaxpet room.maxpet%TYPE;
    
BEGIN
    SELECT maxguest, maxpet INTO vmaxguest, vmaxpet
    FROM room
    WHERE rm_code = :NEW.rm_code; 
    IF vmaxguest < (:NEW.adult + :NEW.child) THEN
        RAISE all_human_exception;
    ELSIF vmaxpet < :NEW.pet  THEN
        RAISE all_pet_exception;
    END IF;

    OPEN insreserve_cursor;
    LOOP
        FETCH insreserve_cursor INTO vci_date,vco_date;
        EXIT WHEN insreserve_cursor%NOTFOUND;
        IF :NEW.ci_date BETWEEN vci_date AND vco_date-1 THEN
            RAISE date_exception;
        ELSIF :NEW.co_date BETWEEN vci_date-1 AND vco_date  THEN
            RAISE date_exception;
        END IF;
    END LOOP;
    CLOSE insreserve_cursor;
EXCEPTION
    WHEN date_exception THEN
        RAISE_APPLICATION_ERROR( -20001, '�ش糯¥�� �̹� ������ �ֽ��ϴ�.' );
    WHEN all_human_exception THEN
        RAISE_APPLICATION_ERROR( -20002, '�ο��� �ִ�����ο��� �ʰ��߽��ϴ�.' );
    WHEN all_pet_exception THEN
        RAISE_APPLICATION_ERROR( -20003, '�ݷ������� �ִ����ݷ������� �ʰ��߽��ϴ�.' );
END;

-- �߰���� ��� �Լ�
CREATE OR REPLACE FUNCTION uf_calc_fee
(
    pprice room.price%TYPE
    
    , pci_date reserve.ci_date%TYPE
    , pco_date reserve.co_date%TYPE
    
    , padult reserve.adult%TYPE
    , pchild reserve.child%TYPE
    , pinfant reserve.infant%TYPE
    , ppet reserve.pet%TYPE
    
    , prm_code room.rm_code%TYPE
)
RETURN NUMBER
IS
    vweekend_price NUMBER;
    vtotal_price NUMBER;
    
    vperson NUMBER(3);
    vci_date reserve.ci_date%TYPE;
    vco_date reserve.co_date%TYPE;
    
    CURSOR vcursor IS (
                            SELECT a.fee_code, a.fee_basis, a.fee_cost
                            FROM feeset a JOIN fee b ON a.fee_code = b.fee_code
                                          JOIN room c ON c.rm_code = a.rm_code
                            WHERE a.rm_code = prm_code
                       );
    
    vfee_code feeset.fee_code%TYPE;
    vfee_basis feeset.fee_basis%TYPE;
    vfee_cost feeset.fee_cost%TYPE;
    
    vdays_count NUMBER;
    vweekend_count NUMBER;
BEGIN    
    -- �⺻��� ����
    vtotal_price := pprice;
    
    -- �ο�
    vperson := padult + pchild;
    
    -- �߰�����ڵ�, �߰���ݱ���, �߰��ݾ�
    FOR vrow IN vcursor
    LOOP
        vfee_code := vrow.fee_code;
        vfee_basis := vrow.fee_basis;
        vfee_cost := vrow.fee_cost;
    END LOOP;
    
    -- �߰���� ����
    -- �ָ���� ����
    IF vfee_code = 'ET4' AND vfee_cost != 0 THEN
        -- �ܼ� �ָ����
        vweekend_price := pprice + vfee_cost;
        
        -- �Ⱓ���� ���� �ϼ� ���ϱ�
        SELECT DISTINCT COUNT( * ) OVER( PARTITION BY week ) daycount INTO vdays_count
        FROM (
                SELECT CASE 
                            WHEN TO_CHAR( TO_DATE( cio ), 'D' ) IN ( '1', '7' ) THEN 'END'
                            ELSE 'DAYS'
                        END week
                FROM (
                        SELECT TO_CHAR( TO_DATE( pci_date, 'YYYYMMDD' ) + LEVEL - 1, 'YYYYMMDD' ) cio
                        FROM ( SELECT TO_CHAR( pci_date, 'YYYYMMDD' ) ci, TO_CHAR( pco_date, 'YYYYMMDD' ) co FROM dual )
                        CONNECT BY LEVEL <= TO_DATE( pco_date, 'YYYYMMDD' ) - TO_DATE( pci_date, 'YYYYMMDD' ) + 1
                      )
              )
        WHERE week = 'DAYS';
        
        -- �Ⱓ���� �ָ� �ϼ� ���ϱ�
        SELECT DISTINCT COUNT( * ) OVER( PARTITION BY week ) daycount INTO vweekend_count
        FROM (
                SELECT CASE 
                            WHEN TO_CHAR( TO_DATE( cio ), 'D' ) IN ( '1', '7' ) THEN 'END'
                            ELSE 'DAYS'
                        END week
                FROM (
                        SELECT TO_CHAR( TO_DATE( pci_date, 'YYYYMMDD' ) + LEVEL - 1, 'YYYYMMDD' ) cio
                        FROM ( SELECT TO_CHAR( pci_date, 'YYYYMMDD' ) ci, TO_CHAR( pco_date, 'YYYYMMDD' ) co FROM dual )
                        CONNECT BY LEVEL <= TO_DATE( pco_date, 'YYYYMMDD' ) - TO_DATE( pci_date, 'YYYYMMDD' ) + 1
                      )
              )
        WHERE week = 'END';      
        
        -- ���� �ָ���� ����
        vtotal_price := ( pprice * vdays_count + vweekend_price * vweekend_count ) / ( vdays_count + vweekend_count );
        
        IF vfee_code = 'ET2' AND vfee_basis > 0 AND vfee_cost != 0 THEN
            vtotal_price := vtotal_price + vfee_cost;
        END IF;
            
        IF vfee_code = 'ET3' AND vperson > vfee_basis AND vfee_cost != 0 THEN
            vtotal_price := vtotal_price + vfee_cost * ( vperson - vfee_basis );
        END IF;
        
    -- �ָ���� ���� X
    ELSE
        IF vfee_code = 'ET2' AND vfee_basis > 0 AND vfee_cost != 0 THEN
            vtotal_price := vtotal_price + vfee_cost;
        END IF;

        IF vfee_code = 'ET3' AND vperson > vfee_basis AND vfee_cost != 0 THEN
            vtotal_price := vtotal_price + vfee_cost * ( vperson - vfee_basis );
        END IF;
        
    END IF;
    
    RETURN( vtotal_price );
-- EXCEPTION
END;

-- �ְ������� ��� �Լ�
CREATE OR REPLACE FUNCTION uf_calc_dc
(
    pci_date reserve.ci_date%TYPE
    , pco_date reserve.co_date%TYPE
    
    , prm_code room.rm_code%TYPE
)
RETURN NUMBER
IS
    vnight NUMBER;
    
    CURSOR vdccursor IS (
                            SELECT a.dc_code, a.dc_basis, a.rate
                            FROM dcset a JOIN dc b ON a.dc_code = b.dc_code
                                          JOIN room c ON c.rm_code = a.rm_code
                            WHERE a.rm_code = prm_code
                         );

    vdc_code VARCHAR2(10);
    vdc_basis NUMBER(3);
    vrate NUMBER;

    vweek_rate dcset.rate%TYPE;
    vmonth_rate dcset.rate%TYPE;
    vearly_rate dcset.rate%TYPE;
    vlast_rate dcset.rate%TYPE;
    vmax_rate NUMBER;
BEGIN
    vnight := pco_date - pci_date;

    -- �����ڵ�, ���α���, ������
    FOR vdcrow IN vdccursor
    LOOP
        vdc_code := vdcrow.dc_code;
        vdc_basis := vdcrow.dc_basis;
        vrate := vdcrow.rate;
    END LOOP;

    -- �ְ�����
    IF vdc_code = 'DC1' AND vnight >= vdc_basis AND vrate != 0 AND vrate IS NOT NULL THEN
        vweek_rate := vrate / 100;
    END IF;
    
    -- ��������
    IF vdc_code = 'DC2' AND vnight >= vdc_basis AND vrate != 0 AND vrate IS NOT NULL THEN
        vmonth_rate := vrate / 100;
    END IF;
    
    -- ���⿹������
    IF vdc_code = 'DC3' AND MONTHS_BETWEEN( pci_date, SYSDATE ) >= vdc_basis AND vrate != 0 AND vrate IS NOT NULL THEN
        vearly_rate := vrate / 100;
    END IF;
    
    -- ����������
    IF vdc_code = 'DC4' AND pci_date - SYSDATE <= vdc_basis AND vrate != 0 AND vrate IS NOT NULL THEN
        vlast_rate := vrate / 100;
    END IF;
    
    vmax_rate := GREATEST( vweek_rate, vmonth_rate, vearly_rate, vlast_rate );
    
    RETURN( vmax_rate );
    
-- EXCEPTION
END;

--------------------------------------------------------------------------------
-- ���� �⺻Ű ������
CREATE SEQUENCE seq_res_code
    INCREMENT BY 1
    START WITH 100
    NOMAXVALUE
    NOMINVALUE
    NOCYCLE
    NOCACHE;

--16.���� ���� ���ν���
CREATE OR REPLACE PROCEDURE up_insres
(
    pci_date reserve.ci_date%TYPE
    , pco_date reserve.co_date%TYPE
    
    , padult reserve.adult%TYPE := NULL
    , pchild reserve.child%TYPE := NULL
    , pinfant reserve.infant%TYPE := NULL
    , ppet reserve.pet%TYPE := NULL
    
    , prm_code room.rm_code%TYPE
    , pmem_code member.mem_code%TYPE
)
IS
    vci_date reserve.ci_date%TYPE;
    vco_date reserve.co_date%TYPE;
    vnight NUMBER(3);
    
    vprice room.price%TYPE;
    
    CURSOR vcursor IS (
                            SELECT b.fee_code, fee_basis, fee_cost
                            FROM feeset a JOIN fee b ON a.fee_code = b.fee_code
                                          JOIN room c ON c.rm_code = a.rm_code
                            WHERE a.rm_code = prm_code
                       );
    
    vfee_code feeset.fee_code%TYPE;
    vfee_basis feeset.fee_basis%TYPE;
    vfee_cost feeset.fee_cost%TYPE;
    
    vmax_rate dcset.rate%TYPE;
    
    vrm_code room.rm_code%TYPE;
    vmem_code member.mem_code%TYPE;
    
    vtotal_price NUMBER;
                       
BEGIN
    -- �⺻���
    SELECT price INTO vprice
    FROM room
    WHERE rm_code = prm_code;
    
    -- �⺻��� ����
    vtotal_price := vprice;
    
    -- �߰���� ����
    vtotal_price := vtotal_price + uf_calc_fee( vprice, pci_date, pco_date, padult, pchild, pinfant, ppet, prm_code );

    -- �ڼ� ���ϱ�
    vnight := pco_date - pci_date;

    -- ���ݾ׿� �ڼ� ���ϱ�
    vtotal_price := vtotal_price * vnight;
    
    -- ������ ����
    vmax_rate := uf_calc_dc( pci_date, pco_date, prm_code );
    
    -- ���� ����
    vtotal_price := vtotal_price * NVL( vmax_rate, 1 );
    
    -- �߰�����ڵ�, �߰���ݱ���, �߰��ݾ�
    FOR vrow IN vcursor
    LOOP
        vfee_code := vrow.fee_code;
        vfee_basis := vrow.fee_basis;
        vfee_cost := vrow.fee_cost;
    END LOOP;
    
    -- û�Һ� ����
    IF vfee_code = 'ET1' AND vfee_cost != 0 THEN
        vtotal_price := vtotal_price + vfee_cost;
    END IF;
    
    -- ��ü��� �ݿø�
    vtotal_price := ROUND( vtotal_price );

    INSERT INTO reserve
        VALUES( 'RS' || seq_res_code.NEXTVAL, SYSDATE, pci_date, pco_date, '������ ����', NVL( padult, 0 )
                    , NVL( pchild, 0 ), NVL( pinfant, 0 ), NVL( ppet, 0 ), vtotal_price, prm_code, pmem_code, null );

    COMMIT;
    
    -- ���
    DBMS_OUTPUT.PUT_LINE( TO_CHAR( vtotal_price / vnight, 'L999,999,999' ) || ' / ��' );
    DBMS_OUTPUT.PUT_LINE( 'üũ��' || '    |   ' || 'üũ�ƿ�' );
    DBMS_OUTPUT.PUT_LINE( pci_date || '     ' || pco_date );
    DBMS_OUTPUT.PUT_LINE( '�Խ�Ʈ ' || ( padult + pchild ) || '��' || ', ' || '���� ' || pinfant || '��' || ', ' || '�ݷ����� ' || ppet || '����' );
    DBMS_OUTPUT.PUT_LINE( TO_CHAR( vtotal_price / vnight, 'L999,999,999' ) || ' X ' || vnight || '��' || TO_CHAR( vtotal_price, 'L999,999,999' ) );
    DBMS_OUTPUT.PUT_LINE( '-----------------------------------' );
    DBMS_OUTPUT.PUT_LINE( '�� �հ�' || TO_CHAR( vtotal_price, 'L999,999,999' ) );

-- EXCEPTION
END;
--------------------------------------------------------------------------------
--17.���� ����
CREATE OR REPLACE PROCEDURE up_updres
(
    pres_code reserve.res_code%TYPE
)
IS
    vci_date reserve.ci_date%TYPE;
    vco_date reserve.co_date%TYPE;
    
    vadult reserve.adult%TYPE;
    vchild reserve.child%TYPE;
    vinfant reserve.infant%TYPE;
    vpet reserve.pet%TYPE;
    
    vprice room.price%TYPE;
    vrm_code room.rm_code%TYPE;
    
    CURSOR vcursor IS (
                            SELECT b.fee_code, fee_basis, fee_cost
                            FROM feeset a JOIN fee b ON a.fee_code = b.fee_code
                                          JOIN reserve c ON c.rm_code = a.rm_code
                            WHERE c.res_code = pres_code
                       );
    
    vfee_code feeset.fee_code%TYPE;
    vfee_basis feeset.fee_basis%TYPE;
    vfee_cost feeset.fee_cost%TYPE;
    
    vnight NUMBER;
    vmax_rate NUMBER;
    vtotal_price NUMBER;
BEGIN
    -- ���� ���� ��������
    SELECT ci_date, co_date, adult, child, infant, pet, price, a.rm_code
        INTO vci_date, vco_date, vadult, vchild, vinfant, vpet, vprice, vrm_code
    FROM reserve a JOIN room b ON a.rm_code = b.rm_code
    WHERE res_code = pres_code;
    
    -- �⺻���
    vtotal_price := vprice;
    
    -- �߰����
    vtotal_price := vtotal_price + uf_calc_fee( vprice, vci_date, vco_date, vadult, vchild, vinfant, vpet, vrm_code );
    
    -- �ڼ�
    vnight := vco_date - vci_date; 
    
    -- ���ϱ�
    vtotal_price := vtotal_price * vnight;
    
    -- ������
    vmax_rate := uf_calc_dc( vci_date, vco_date, vrm_code );
    
    -- ���� ����
    vtotal_price := vtotal_price * NVL( vmax_rate, 1 );
    
    -- �߰�����ڵ�, �߰���ݱ���, �߰��ݾ�
    FOR vrow IN vcursor
    LOOP
        vfee_code := vrow.fee_code;
        vfee_basis := vrow.fee_basis;
        vfee_cost := vrow.fee_cost;
    END LOOP;
    
    -- û�Һ� ����
    IF vfee_code = 'ET1' AND vfee_cost != 0 THEN
        vtotal_price := vtotal_price + vfee_cost;
    END IF;
    
    -- ��ü��� �ݿø�
    vtotal_price := ROUND( vtotal_price );
    
    -- �ݿ�
    UPDATE reserve
    SET tot_cost = vtotal_price
    WHERE res_code = pres_code;
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE( '������ �����Ǿ����ϴ�.' );
-- EXCEPTION
END;
--------------------------------------------------------------------------------
--18.���� ����
CREATE OR REPLACE PROCEDURE up_delres
(
    pres_code reserve.res_code%TYPE
)
IS
    vpay_code pay.pay_code%TYPE;
    
    vcount NUMBER(1);
    
    v_no_res_cancel EXCEPTION;
BEGIN    
    SELECT COUNT(*) INTO vcount
    FROM pay
    WHERE res_code = pres_code;
    
    IF vcount != 0 THEN
        RAISE v_no_res_cancel;
    ELSE
        DELETE FROM reserve
        WHERE res_code = pres_code;
        
        DBMS_OUTPUT.PUT_LINE( '������ ��ҵǾ����ϴ�.' );
    END IF;
    
    COMMIT;
    
EXCEPTION
    WHEN v_no_res_cancel THEN
        RAISE_APPLICATION_ERROR( -20022, 'ȯ���� ���ֽʽÿ�' );
END;
--------------------------------------------------------------------------------
