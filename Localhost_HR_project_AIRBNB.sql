--로그인(전화번호)로 하는 방법 
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
    
IF vmem_phonecheck = 1 THEN --전화번호는 고유한 값이므로 일치하면 로그인 성공
DBMS_OUTPUT.PUT_LINE('로그인 성공!!!!');

ELSE
DBMS_OUTPUT.PUT_LINE('계정이 존재하지 않습니다. 회원가입 부탁드립니다.');
END IF;
END;

EXEC login('한국','01096336892'); --로그인성공

EXEC login('한국','01096336890'); --로그인 실패

--로그인(이메일)로 하는 방법
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
DBMS_OUTPUT.PUT_LINE('로그인 성공!!!!');

ELSE
DBMS_OUTPUT.PUT_LINE('계정이 존재하지 않습니다. 회원가입 부탁드립니다.');
END IF;
END;

EXEC login_em('jek3118@naver.com');

EXEC login_em('lavender@naver.com');


--회원가입 
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
    --회원코드가 ME1형식으로 구성이 되어있는데, 회원코드는 회원수가 늘어날 수록 1이 추가되어야 하기 때문에
    --세전째 숫자를 잘라와서 그 잘라온 숫자를 넘버로 주고, 그 값의 최대값을 뽑아서 +1을한 값을 회원코드변수에 저장을 해줍니다.
    SELECT 'ME' || TO_CHAR( NVL( MAX( TO_NUMBER( SUBSTR( mem_code, 3 ) ) ), 0 ) + 1 ) INTO vmember_code
    FROM member;
    
    INSERT INTO member(mem_code,mem_name,birth,mem_email,mem_phone,country) 
    values (vmember_code,pmem_name,pbirth,pmem_email,pmem_phone,pcountry);
EXCEPTION
        WHEN VALUE_ERROR THEN
            RAISE_APPLICATION_ERROR(-20011, '>입력하신 데이터 값이 너무 큽니다.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20012, '>회원 가입이 불가능 합니다.');   
END;

EXEC up_inssign('촤진우','990825','qwer14@naver.com','01012349999','한국');

SELECT *
FROM MEMBER;

--회원가입 수정  
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
         mem_name = NVL(pmem_name, vmem_name) --NVL코드를 사용해 수정하고 싶지 않은 값이 있다면, 기존의 데이터가 들어가도록 구현
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
            RAISE_APPLICATION_ERROR(-20002, '>일치하는 회원정보를 찾을수 없습니다.');
        WHEN VALUE_ERROR THEN
            RAISE_APPLICATION_ERROR(-20003, '>입력하신 데이터 값이 너무 큽니다.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20004, '>회원 수정이 불가능 합니다.');
END;


EXEC UP_memupd('ME41','박대기','pjw8888@gmail.com','01022223333','Y','역삼역 3번 출구','01055556666','우리은행','555555555'); --이름변경 및 추가등록
EXEC UP_memupd( pmem_code =>'ME41', pbank =>'카카오뱅크' ); --특정 값만 변경할 경우

EXEC UP_memupd('ME41','박대기','pjw8888@gmail.com','010222233330000000000000000','Y','역삼역 3번 출구','01055556666','우리은행','555555555');



--회원 삭제하기
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
            RAISE_APPLICATION_ERROR(-20005, '>일치하는 회원정보를 찾을수 없습니다.');
    WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20006, '>회원탈퇴가 불가능 합니다.');
END mem_del;

EXECUTE mem_del('01022223333');


select *
from member;
--------------------------------------------------------------------------------

--------------------------------------------------------
    1. 숙소등록 
--------------------------------------------------------
1. 숙소등록 

1) 필수정보등록
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
    -- 숙소코드 붙여주기 
    SELECT 'RM' 
        || TO_CHAR( NVL( MAX( TO_NUMBER( SUBSTR( rm_code, 3 ) ) ), 0 ) + 1 )
    INTO vrm_code
    FROM room; 
    
    -- 값 삽입 
    INSERT INTO room (rm_code, country, ref_policy, rm_type, space 
                 , rm_name, maxguest, rm_info , price
                 , rm_loc,bedroom,bed,bathroom ,admin_code)
        VALUES( vrm_code, pcountry, pref_policy, prm_type, pspace
            , prm_name , pmaxguest , prm_info, pprice 
            ,prm_loc, pbedroom, pbed, pbathroom, padmin_code);
    COMMIT; 
    
    --확인 
    DBMS_OUTPUT.PUT_LINE(vrm_code||','|| pcountry ||','|| pref_policy||','|| prm_type||','|| pspace
            ||','|| prm_name ||','|| pmaxguest ||','|| prm_info ||','|| pprice 
            ||','|| prm_loc||','||pbedroom||','|| pbed||','|| pbathroom||','||padmin_code);
            
    DBMS_OUTPUT.PUT_LINE('숙소 기본정보를 입력했습니다! 다음으로 사진을 입력해 주세요! '); 

END ; --Procedure UP_INSRULE이(가) 컴파일되었습니다.

[실행]
EXEC up_insRoom ('미국','유연','해변바로앞','개인실','해변 앞 아파트126',4,'시원한 바닷바람과 함께 재밌게 서핑을 배워보세요! 강습비용은 무료입니다.',331242,'하와이, 미국',2,3,2,'AD7'); 

SELECT *
FROM room;

2) 사진등록  
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
    -- 룸코드 : 현재 가입하고 있는 숙소 번호 
    SELECT 'RM' || TO_CHAR( NVL( MAX( TO_NUMBER( SUBSTR( rm_code, 3 ) ) ), 0 ) )
    INTO vrm_code
    FROM room;
    
    -- 포토코드 
    SELECT NVL( MAX( TO_NUMBER( SUBSTR( photo_code, 4 ) ) ), 0 ) + 1 
    INTO vimageindex 
    FROM photo; 

    -- 각각의 사진 주소 삽입  
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
    
    DBMS_OUTPUT.PUT_LINE('숙소 사진등록에 성공하였습니다.'); 
    COMMIT; 
END; --Procedure UP_INSPHOTO이(가) 컴파일되었습니다.

[실행] 
EXEC up_insPhoto ('C:\Class\WorkSpace\OracleClass\숙소이미지.바다.jpg','C:\Class\WorkSpace\OracleClass\숙소이미지.모래.jpg','C:\Class\WorkSpace\OracleClass\숙소이미지.바람.jpg','C:\Class\WorkSpace\OracleClass\숙소이미지.파도.jpg','C:\Class\WorkSpace\OracleClass\숙소이미지.해먹.jpg') ; 

SELECT *
FROM photo;

3) 숙소상태
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

    IF vrm_status = '비활성화' THEN
        RAISE v_no_more_visible;
    ELSE 
        UPDATE room
        SET rm_status = prm_status
        WHERE rm_code = prm_code;
        
        -- 운영중, 운영중지는 화면에 숙소 출력할 때 WHERE 조건절로 나오게, 안나오게
    IF prm_status = '비활성화' THEN
            --삭제
        DELETE FROM WISHLIST WHERE rm_code = prm_code;
        DELETE FROM REGISTER WHERE rm_code = prm_code;
        DELETE FROM RULESET WHERE rm_code = prm_code;
        DELETE FROM FACSET WHERE rm_code = prm_code;
        DELETE FROM PHOTO WHERE rm_code = prm_code;
        DELETE FROM DCSET WHERE rm_code = prm_code;
        DELETE FROM FEESET WHERE rm_code = prm_code;
            -- 예약 상태 변경
            UPDATE reserve
            SET res_status = '예약거절'
            WHERE rm_code = prm_code;
        END IF;
    END IF;
EXCEPTION
    WHEN v_no_more_visible THEN 
        RAISE_APPLICATION_ERROR(-20012, '이미 비활성화된 숙소입니다') ; 
        ROLLBACK;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('기타 오류 발생');
        ROLLBACK;
END;
    
[실행] 
EXEC up_updRoomStatus( 'RM33', '운영정지' );

SELECT rm_code, rm_status
FROM room;

SELECT *
FROM wishlist;
SELECT *
FROM reserve;


---------------------------------------------------------------------------
3. 숙소정보 수정
---------------------------------------------------------------------------

1) 숙소명 수정 
CREATE OR REPLACE PROCEDURE up_updRoomname
(
    prm_code room.rm_code%TYPE,
    prm_name room.rm_name%TYPE
) 
IS 
BEGIN
    IF LENGTH(prm_name) > 50 THEN -- 제한 길이를 초과하는 경우
        RAISE VALUE_ERROR; -- VALUE_ERROR 예외 발생
    
    ELSE -- 설제한 길이 이하인 경우
        UPDATE room 
        SET rm_name = prm_name 
        WHERE rm_code = prm_code;
    COMMIT; 
    END IF; 
    
    DBMS_OUTPUT.PUT_LINE('숙소 이름을 변경했습니다!   숙소코드'||prm_code);
    DBMS_OUTPUT.PUT_LINE('변경된 숙소이름 : '||prm_name);

EXCEPTION 
    WHEN VALUE_ERROR THEN 
        RAISE_APPLICATION_ERROR(-20001, 'TOO LONG VALUE') ;
        DBMS_OUTPUT.PUT_LINE('>숙소 이름은 50자 이하로 입력하세요.');
    WHEN OTHERS THEN 
        RAISE_APPLICATION_ERROR(-20002, 'UNKNOWN PROBLEM') ; 
        DBMS_OUTPUT.PUT_LINE('해당 요청을 정상적으로 처리할 수 없습니다');

END; --Procedure UP_UPDROOMNAME이(가) 컴파일되었습니다.

[실행] 
EXEC up_updRoomname('RM13', '우리집' ); 
EXEC up_updRoomname('RM17', '우리집우리집우리집우리집우리집우리집우리우리집우리집우리집우리집우리집우리집우리집우리집우리우리집우리집우리집우리집우리집우리집우리집우리집우리집우리집우리집우리집우리집우리집우리집우리집' )  ; 
--UNKNOWN PROBLEM

SELECT rm_code, rm_name
FROM room;
DESC room

2) 숙소설명 수정 
CREATE OR REPLACE PROCEDURE up_updRoomloc
(
    prm_code room.rm_code%TYPE,
    prm_info room.rm_info%TYPE
)
IS
BEGIN
    IF LENGTH(prm_info) > 200 THEN -- 설명 길이가 제한 길이를 초과하는 경우
        RAISE VALUE_ERROR; -- VALUE_ERROR 예외 발생
    ELSE -- 설명 길이가 제한 길이 이하인 경우
        UPDATE room
        SET rm_info = prm_info
        WHERE rm_code = prm_code;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('숙소 설명을 변경했습니다! 숙소코드'||prm_code);
        DBMS_OUTPUT.PUT_LINE('변경된 숙소설명 : '||prm_info);
    END IF;
EXCEPTION
    WHEN VALUE_ERROR THEN 
    RAISE_APPLICATION_ERROR(-20001, 'TOO LONG VALUE') ;
    DBMS_OUTPUT.PUT_LINE('>숙소 이름은 50자 이하로 입력하세요.');
    
    WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-22222, '해당 요청을 정상적으로 처리할 수 없습니다.');
END; 

[실행] 
EXEC up_updRoomloc('RM16', '설명을 바꿔봅시다'); 
EXEC up_updRoomloc('RM16', '설명을 바꿔봅시다설명을 바꿔봅시다설명을 바꿔봅시다설명을 바꿔봅시다설명을 바꿔봅시다설명을 바꿔봅시다설명을 바꿔봅시다설명을 바꿔봅시다설명을 바꿔봅시다설명을 바꿔봅시다설명을 바꿔봅시다설명을 바꿔봅시다설명을 바꿔봅시다설명을 바꿔봅시다설명을 바꿔봅시다설명을 바꿔봅시다설명을 바꿔봅시다설명을 바꿔봅시다설명을 바꿔봅시다설명을 바꿔봅시다설명을 바꿔봅시다설명을 바꿔봅시다설명을 바꿔봅시다설명을 바꿔봅시다설명을 바꿔봅시다'); 

SELECT rm_code, rm_info
FROM room;


3) 게스트수 
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
     DBMS_OUTPUT.PUT_LINE('게스트수 1명증가');
    ELSE 
     vmaxguest := vmaxguest - 1; 
     DBMS_OUTPUT.PUT_LINE('게스트수 1명감소');
    END IF;
     
    UPDATE room 
        SET maxguest = vmaxguest
    WHERE rm_code = prm_code;
    
    COMMIT; 
    DBMS_OUTPUT.PUT_LINE('총 게스트수 '||vmaxguest);

END; --Procedure UP_UPDMAXGUEST이(가) 컴파일되었습니다.

[실행] 
EXEC up_updMaxguest('RM17', '+'); 
EXEC up_updMaxguest('RM17', '-'); 

SELECT rm_code, maxguest
FROM room
WHERE rm_code = 'RM17'; 



4)주소 수정 
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
    DBMS_OUTPUT.PUT_LINE('주소를 변경했습니다!숙소코드'||prm_code);
    DBMS_OUTPUT.PUT_LINE('변경된 주소 : '||prm_loc);
END ; -- Procedure UP_UPDROOMLOC이(가) 컴파일되었습니다.

[실행] 
EXEC UP_UPDROOMLOC('RM3', '강남구, 서울특별시, 한국');

SELECT rm_code, rm_loc
FROM room;

5) 숙소유형 & 예약가능공간 수정 
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
    
    DBMS_OUTPUT.PUT_LINE('숙소유형을 변경했습니다!숙소코드 : '||prm_code);
    DBMS_OUTPUT.PUT_LINE('변경된 숙소유형 : '||prm_type|| '  /   예약가능공간 : '|| pspace);
END ; --Procedure UP_UPDROOMTYPE이(가) 컴파일되었습니다.


[실행] 
EXEC UP_UPDROOMTYPE('RM12', '전원주택', '다인실') ; 

SELECT rm_code, rm_type, space
FROM room 
WHERE rm_code = 'RM12' ; 

6) 침실&침대&욕실 
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
        RAISE_APPLICATION_ERROR(-20001, '더 이상 뺄 수 없습니다');
    END IF;

    UPDATE room 
    SET bedroom = vbedroom, bed = vbed, bathroom = vbathroom
    WHERE rm_code = prm_code; 
    COMMIT; 
    
    DBMS_OUTPUT.PUT_LINE('총 침실 수 '|| vbedroom);
    DBMS_OUTPUT.PUT_LINE('총 침대 수 '|| vbed);
    DBMS_OUTPUT.PUT_LINE('총 욕실 수 '|| vbathroom);
END;


[실행] 
EXEC up_updNecessity('RM17', 1,-1,2) ; --213
EXEC up_updNecessity('RM17', pupdown_bedroom => 1, pupdown_bed => 2 ) ; --333
EXEC UP_UPDNECESSITY('RM17', pupdown_bed =>-1) ; 

SELECT bedroom, bed, bathroom
FROM room 
WHERE rm_code = 'RM17' --232 141

7) 1박당 요금
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
        DBMS_OUTPUT.PUT_LINE('기본 요금을 낮추어 예약 가능성을 높여보세요
                                회원님 지역의 수요에 따라 요금을 조정하면 예약률이 높아질 수 있습니다.');
    ELSE 
        DBMS_OUTPUT.PUT_LINE('스마트 요금으로 더 높은 수입을 올리세요.
                                경쟁력 있는 요금을 설정해 예약을 더 많이 받고 장기적으로 
                                더 높은 수입을 올리실 수 있도록 에어비앤비가 도와드리겠습니다.');
    END IF ; 
    
    UPDATE room
    SET price = pprice
    WHERE rm_code = prm_code; 
    COMMIT; 
    
    DBMS_OUTPUT.PUT_LINE('1박당 요금을 변경했습니다!숙소코드 : '||prm_code);
    DBMS_OUTPUT.PUT_LINE('변경된 요금 : '||pprice);
END ; -- Procedure UP_UPDPRICE이(가) 컴파일되었습니다.

[실행] 
EXEC UP_UPDPRICE('RM17', 100000); 
EXEC UP_UPDPRICE('RM17', 200000); 

SELECT rm_code, price
FROM room
WHERE rm_code = 'RM17'; 

UPDATE room
SET price = 10000
WHERE price >= 800000; 
지금 평균 : 801624

8) 환불정책 
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
    
    DBMS_OUTPUT.PUT_LINE('환불정책을 변경했습니다!숙소코드 : '||prm_code);
    DBMS_OUTPUT.PUT_LINE('변경된 환불정책 : '||pref_policy);
END ; -- Procedure UP_UPDREFPOLICY이(가) 컴파일되었습니다.

[실행] 
EXEC UP_UPDREFPOLICY('RM17', '엄격') ; 

SELECT * 
FROM room
WHERE rm_code = 'RM17'; 


9) 사업자 등록번호 등록 

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
    
    DBMS_OUTPUT.PUT_LINE('사업자 등록번호를 등록했습니다! 숙소코드 : '||prm_code);
    DBMS_OUTPUT.PUT_LINE('사업자 등록번호 : '||prm_number);
END ; -- Procedure UP_UPDNUMBER이(가) 컴파일되었습니다.

[실행] 
EXEC UP_UPDNUMBER('RM42',5262617323); 

SELECT *
FROM room
WHERE rm_code = 'RM42'; 

10) 체크인, 체크아웃 시간 수정 
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
    
    DBMS_OUTPUT.PUT_LINE('체크인/ 체크아웃 시간을 등록했습니다! 숙소코드 : '||prm_code);
    DBMS_OUTPUT.PUT_LINE('체크인 시간 : '||pci_time );
    DBMS_OUTPUT.PUT_LINE('체크아웃 시간 : '||pco_time );
    
EXCEPTION 
    WHEN v_cannot_reserve_exception THEN 
        RAISE_APPLICATION_ERROR(-20999,'오전 1시~7시는 체크인 할 수 없습니다.') ; 
END ;--Procedure UP_UPDROOMTIME이(가) 컴파일되었습니다.

[실행] 
EXEC UP_UPDROOMTIME('RM42', '15:00','13:00') 
EXEC UP_UPDROOMTIME('RM42', '2:00','13:00') 

SELECT rm_code, ci_time, co_time
FROM room
WHERE rm_code = 'RM42';

--------------------------------------------------------
    3. 추가설정 및 수정 
--------------------------------------------------------

1. 편의시설 
1) 편의시설설정 등록
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
END;    --Procedure UP_INSFAC이(가) 컴파일되었습니다.

[실행] 
EXEC UP_INSFAC('RM17', 'FA8'); 

SELECT * 
FROM facset
WHERE rm_code = 'RM17'; 


2) 편의시설설정 삭제 
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
END; --Procedure UP_DELFACSET이(가) 컴파일되었습니다.

[실행] 
EXEC UP_DELFACSET('RM17','FA8'); 

SELECT * 
FROM facset
WHERE rm_code = 'RM17'; 


2. 이용규칙 
1) 이용규칙 설정 
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

[실행] 
EXEC up_insRuleSet( 'RU3', 'RM40', null );
EXEC up_insRuleSet( 'RU2', 'RM40', 5 );

SELECT *
FROM ruleset
WHERE rm_code = 'RM40'
ORDER BY ruleset_code;

SELECT rm_code, maxpet
FROM room
WHERE rm_code = 'RM40';

2) 이용규칙 삭제 
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

[실행] 
EXEC up_delRuleSet( 'RU3', 'RM40' );
EXEC up_delRuleSet( 'RU2', 'RM40' );

SELECT *
FROM ruleset
WHERE rm_code = 'RM40'
ORDER BY ruleset_code;

SELECT *
FROM feeset;



3) 할인설정 
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
        RAISE_APPLICATION_ERROR(-20013, '할인기준은 필수입력 값입니다');
        ROLLBACK;
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('기타 오류 발생');
      ROLLBACK;
END;

[실행] 
EXEC up_insDcSet( 'DC1', 'RM3', '10', null );
EXEC up_insDcSet( 'DC2', 'RM3', '20', null );
EXEC up_insDcSet( 'DC3', 'RM3', '30', 90 );
EXEC up_insDcSet( 'DC4', 'RM3', '40', 3 );
EXEC up_insDcSet( 'DC4', 'RM3', '50', null );

SELECT *
FROM dcset
WHERE rm_code = 'RM3'
ORDER BY dcset_code;


4) 할인설정 변경 & 삭제
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

[실행]
EXEC up_updDcSet( 'DC1', 'RM3', '15', null );
EXEC up_updDcSet( 'DC2', 'RM3', '0', null );
EXEC up_updDcSet( 'DC3', 'RM3', '35', 100 );
EXEC up_updDcSet( 'DC4', 'RM3', '45', null );

SELECT *
FROM dcset;


4. 추가요금 

1) 추가요금 설정 
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

[실행] 
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


2) 추가요금 수정 
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

[실행]              
EXEC up_updFeeSet( 'ET1', 'RM23', 0, null );
EXEC up_updFeeSet( 'ET2', 'RM23', 0, null );
EXEC up_updFeeSet( 'ET3', 'RM23', 20000, 4 );
EXEC up_updFeeSet( 'ET4', 'RM23', 25000, null );


SELECT *
FROM feeset;
                 
                 
    




--------------------------------------------------------------------------------
--1.숙소유형에 따른 숙소검색
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
            --평점이 있는 경우에는 평점이 출력되고,없는 경우에는 평점이 출력되지 않는다.
            IF vrm_avg IS NOT NULL  THEN
                DBMS_OUTPUT.PUT_LINE('사진 : '||vpath ||' / 숙소이름 : '||vrm_name
                                    ||' / 위치 : '||vrm_loc||' / 요금 : '||vprice||' /박 / 평점 : '||vrm_avg);
                DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------------------');
            ELSE
                DBMS_OUTPUT.PUT_LINE('사진 : '||vpath ||' / 숙소이름 : '||vrm_name||' / 위치 : '||vrm_loc||' / 요금 : '||vprice||' /박');
                DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------------------');
            END IF;
        END LOOP;
    CLOSE rinfo_cursor;
END;

EXEC up_roomMainPage('해변바로앞');
--------------------------------------------------------------------------------
--2.위시리스트 조회
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
                        SELECT rm_loc||'의 '||space,rm_name,bed
                        FROM wishlist w LEFT JOIN room r ON w.rm_code=r.rm_code
                        WHERE mem_code=pmem_code
    );
BEGIN
    OPEN wishlist_cursor;
        LOOP
            FETCH wishlist_cursor INTO vrm_loctype,vrm_name,vbed;
            EXIT WHEN wishlist_cursor%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('숙소 위치,타입 : '||vrm_loctype
                                    ||' / 숙소 이름 : '||vrm_name||' / 침대 : '||vbed||'개');
            DBMS_OUTPUT.PUT_LINE('------------------------------------------------------');
        END LOOP;
    CLOSE wishlist_cursor;
END;

EXEC up_wishlist('ME33');

--------------------------------------------------------------------------------
--위시리스트 SEQUENCE 생성
CREATE SEQUENCE seq_wishlist
START WITH 15
NOCYCLE
NOCACHE;

--트리거 (위시리스트에 하나의 회원은 같은 숙소를 등록할 수 없다)
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
        RAISE_APPLICATION_ERROR(-20051,'이미 위시리스트에 있습니다.');
END;

--3.위시리스트 추가
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
    DBMS_OUTPUT.PUT_LINE('위시리스트가 추가되었습니다.');
EXCEPTION
    WHEN mem_code_null  THEN
        RAISE_APPLICATION_ERROR(-20051,'위시리스트 추가 되지않았습니다. 멤버코드를 입력해주세요.');
    WHEN rm_code_null   THEN
        RAISE_APPLICATION_ERROR(-20052,'위시리스트 추가 되지않았습니다. 숙소코드를 입력해주세요.');
END;

EXEC UP_INSWISHLIST('ME2','RM17');

--------------------------------------------------------------------------------
--4.위시리스트 삭제
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
    DBMS_OUTPUT.PUT_LINE('위시리스트가 삭제되었습니다.');
EXCEPTION
    WHEN mem_code_null  THEN
        RAISE_APPLICATION_ERROR(-20061,'위시리스트 삭제 되지않았습니다. 멤버코드를 입력해주세요.');
    WHEN rm_code_null   THEN
        RAISE_APPLICATION_ERROR(-20062,'위시리스트 삭제 되지않았습니다. 숙소코드를 입력해주세요.');
END;

--------------------------------------------------------------------------------
--숙소의 후기개수 구하는 함수 : uf_reviewcount(숙소코드)
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
        RAISE_APPLICATION_ERROR(-20071,'숙소코드를 입력해 주세요.');
END;

--해당숙소의 후기총평점 구하는 함수 uf_reviewavg(숙소코드)
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
    --평점 구하는 쿼리
    SELECT ROUND((SUM(rev_clean)/COUNT(*)+SUM(rev_correct)/COUNT(*)+SUM(rev_contact)/COUNT(*)+SUM(rev_loc)/COUNT(*)+SUM(rev_ci)/COUNT(*)+SUM(rev_price)/COUNT(*))/6,2) INTO vavg
    FROM REVIEW r JOIN RESERVE s ON r.rev_code=s.rev_code
    WHERE rm_code = prm_code;
    RETURN(vavg);
EXCEPTION
    WHEN rm_code_null   THEN
        RAISE_APPLICATION_ERROR(-20081,'숙소코드를 입력해 주세요.');
END;

--5.후기 조회
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
        SELECT mem_name,TO_CHAR(rev_date,'YYYY"년" MM"월"'),content
        FROM review r JOIN reserve s ON r.rev_code = s.rev_code
                     JOIN member m ON s.mem_code = m.mem_code
        WHERE rm_code = prm_code
        ORDER BY rev_date DESC;
    
BEGIN
    IF prm_code IS NULL THEN
        RAISE rm_code_null;
    END IF;
    --각 항목별 평균쿼리
    SELECT AVG(rev_clean),AVG(rev_correct),AVG(rev_contact),AVG(rev_loc),AVG(rev_ci),AVG(rev_price)
    INTO vclean,vcorrect,vcontact,vloc,vci,vprice
    FROM review r JOIN reserve s ON r.rev_code=s.rev_code
    WHERE rm_code = prm_code;
    
    --총평점,후기개수 구하는 함수사용
    vtotavg := uf_reviewavg(prm_code);
    vrevcount := uf_reviewcount(prm_code);
    
    DBMS_OUTPUT.PUT_LINE('★ '||vtotavg||' 후기 '||vrevcount||' 개');
    DBMS_OUTPUT.PUT_LINE('청결도 : '||vclean);
    DBMS_OUTPUT.PUT_LINE('정확성 : '||vcorrect);
    DBMS_OUTPUT.PUT_LINE('의소소통 : '||vcontact);
    DBMS_OUTPUT.PUT_LINE('위치 : '||vloc);
    DBMS_OUTPUT.PUT_LINE('체크인 : '||vci);
    DBMS_OUTPUT.PUT_LINE('가격 대비 만족 : '||vprice);
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------');
    
    OPEN review_cursor;
        LOOP
            FETCH review_cursor INTO vmem_name,vrev_date,vcontent;
            --후기가 6개까지출력된다
            EXIT WHEN review_cursor%NOTFOUND OR review_cursor%ROWCOUNT>6;
            DBMS_OUTPUT.PUT_LINE('회원 이름 : '||vmem_name);
            DBMS_OUTPUT.PUT_LINE('날짜 : '||vrev_date);
            DBMS_OUTPUT.PUT_LINE('리뷰 내용 : '||vcontent);
            DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
        END LOOP;
    CLOSE review_cursor;
EXCEPTION
    WHEN rm_code_null   THEN
        RAISE_APPLICATION_ERROR(-20091,'숙소코드를 입력해 주세요.');
END;

EXEC up_review('RM17');

--------------------------------------------------------------------------------
--후기 SEQUENCE 생성
CREATE SEQUENCE seq_review
START WITH 28
NOCYCLE
NOCACHE;

--트리거 (후기작성은 완료된 여행만 가능하고 하나만 가능하다.)
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
    
    IF vres_status = '취소된 여행' THEN
        RAISE res_status_cancel;
    ELSIF vres_status = '예정된 여행'    THEN
        RAISE res_status_notyet;
    ELSIF revcount =1  THEN
        RAISE revcount_exception;
    END IF;
EXCEPTION
    WHEN res_status_cancel   THEN
        RAISE_APPLICATION_ERROR(-20041,'취소된 여행 이므로 후기를 작성할 수 없습니다.');
    WHEN res_status_notyet   THEN
        RAISE_APPLICATION_ERROR(-20042,'여행 하기 전 이므로 후기를 작성할 수 없습니다.');
    WHEN revcount_exception   THEN
        RAISE_APPLICATION_ERROR(-20043,'이미 후기를 작성하셨습니다.');
END;

--6.후기 추가
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
    DBMS_OUTPUT.PUT_LINE('리뷰가 추가 되었습니다.');
EXCEPTION
    WHEN rev_clean_null   THEN
        RAISE_APPLICATION_ERROR(-20101,'청결도 점수가 입력되지 않았습니다.');
    WHEN rev_correct_null   THEN
        RAISE_APPLICATION_ERROR(-20102,'정확성 점수가 입력되지 않았습니다.');
    WHEN rev_contact_null   THEN
        RAISE_APPLICATION_ERROR(-20103,'의사소통 점수가 입력되지 않았습니다.');
    WHEN rev_loc_null   THEN
        RAISE_APPLICATION_ERROR(-20104,'위치 점수가 입력되지 않았습니다.');    
    WHEN rev_ci_null   THEN
        RAISE_APPLICATION_ERROR(-20105,'체크인 점수가 입력되지 않았습니다.');   
    WHEN rev_price_null   THEN
        RAISE_APPLICATION_ERROR(-20106,'가격대비만족도 점수가 입력되지 않았습니다.');   
END;



--------------------------------------------------------------------------------
--7.후기 수정
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
    --항목별 점수를 수정하면 수정한값으로 , 그렇지않으면 그전의 값 그대로 UPDATE
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
    DBMS_OUTPUT.PUT_LINE('리뷰가 수정 되었습니다.');
END;

--------------------------------------------------------------------------------
--트리거 (후기가 삭제되기전 예약테이블에 후기코드 null로 변경)
CREATE OR REPLACE TRIGGER ut_DELreviewB
BEFORE DELETE ON review
FOR EACH ROW
BEGIN
    UPDATE reserve
    SET rev_code = NULL
    WHERE rev_code = :OLD.rev_code;
END;

--8.후기 삭제
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
    DBMS_OUTPUT.PUT_LINE('후기가 삭제 되었습니다.');
EXCEPTION
    WHEN rev_code_null   THEN
    DBMS_OUTPUT.PUT_LINE('후기코드를 입력해주세요.');
END;

--------------------------------------------------------------------------------
--9.숙소 편의시설 조회
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
            DBMS_OUTPUT.PUT_LINE('편의시설 종류 : '||vfa_type);
            DBMS_OUTPUT.PUT_LINE('편의시설 이름 : '||vfa_name);
        END LOOP;
    CLOSE facility_cursor;
EXCEPTION
    WHEN rm_code_null   THEN
        RAISE_APPLICATION_ERROR(-20111,'숙소코드를 입력해주세요');
END;

EXEC up_facility('RM17');

--------------------------------------------------------------------------------
--10.숙소 이용규칙 조회
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
            DBMS_OUTPUT.PUT_LINE('게스트 조건 ');
            DBMS_OUTPUT.PUT_LINE('게스트 정원 : '||vmaxguest);
            IF vmaxpet IS NULL OR vmaxpet=0 THEN
                vcanpet := '가능';
            ELSE 
                vcanpet := '불가능';
            END IF;
            DBMS_OUTPUT.PUT_LINE('반려동물 동반 '||vcanpet);
            DBMS_OUTPUT.PUT_LINE('체크인 가능 시간 : '||vci_time);
            DBMS_OUTPUT.PUT_LINE('체크인 가능 시간 : '||vco_time);
            DBMS_OUTPUT.PUT_LINE(vrule_type);  
        END LOOP;
    CLOSE rr_cursor;
END;

EXEC up_ruleset('RM17');

--------------------------------------------------------------------------------
--결제 SEQUENCE 생성
CREATE SEQUENCE seq_pay
START WITH 21
NOCYCLE
NOCACHE;

--트리거 (예약상태가 '예정된 여행'이 아니면 결제를 할 수 있다)
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
    
    IF vres_status = '완료된 여행'  THEN
        RAISE res_status_already_exception;
    ELSIF vres_status = '완료된 여행'  THEN
        RAISE res_status_cancel_exception;
    END IF;
EXCEPTION
    WHEN res_status_already_exception   THEN
        RAISE_APPLICATION_ERROR(-20031,'완료된 여행이기 때문에 결제가 불가능 합니다.');
    WHEN res_status_cancel_exception   THEN
        RAISE_APPLICATION_ERROR(-20032,'취소된 여행이기 때문에 결제가 불가능 합니다.');
END;

--트리거 (결제는 삭제할 수 없다, 결제 후에는 취소가 아닌 환불이기 때문에)
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
        RAISE_APPLICATION_ERROR(-20041,'결제 취소는 환불을 이용해 주세요.');
END;

--11.결제 추가
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
    vpay_country := NVL(ppay_country,'한국');
    INSERT INTO pay
    VALUES('PA'||seq_pay.NEXTVAL,ppay_country,SYSDATE,pcardnum,pexpiredate,pcvc,ppostcode,pres_code,pmem_code);
    COMMIT;
END;

select *
from pay;

--------------------------------------------------------------------------------
--12.결제 정보 조회
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
        DBMS_OUTPUT.PUT_LINE('예약 코드 : '||vres_code);
        DBMS_OUTPUT.PUT_LINE('숙소 이름 : '||vrm_name);
        DBMS_OUTPUT.PUT_LINE('결제자 이름 : '||vmem_name);
        DBMS_OUTPUT.PUT_LINE('결제 날짜 : '||vpay_date);
        DBMS_OUTPUT.PUT_LINE('카드번호 : '||vcardnum);
        DBMS_OUTPUT.PUT_LINE('만료 날짜 : '||vexpiredate);
        DBMS_OUTPUT.PUT_LINE('우편 번호 : '||vpostcode);
        DBMS_OUTPUT.PUT_LINE('결제 금액 : '||vtot_cost);
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    END LOOP;
    CLOSE payinfo_cursor;
END;

EXEC up_pay('PA1');

--------------------------------------------------------------------------------
--13.예약 정보 조회
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
                                    SELECT rm_name,TO_CHAR(ci_date,'MM"월"DD"일"(DY)'),ci_time,TO_CHAR(co_date,'MM"월"DD"일"(DY)'),co_time,rm_loc,mem_name,rm_loc
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
        DBMS_OUTPUT.PUT_LINE(vrm_name||' 숙소 예약이 완료되었습니다.');
        DBMS_OUTPUT.PUT_LINE('체크인 : '||vci_date||' '||vci_time);
        DBMS_OUTPUT.PUT_LINE('체크아웃 : '||vco_date||' '||vco_time);
        DBMS_OUTPUT.PUT_LINE('찾아가는 방법 : '||vrm_loc);
        DBMS_OUTPUT.PUT_LINE('찾아가는 방법 : 안내 및 숙소 이용규칙');
        DBMS_OUTPUT.PUT_LINE('호스트에게 메시지 보내기 : '||vmem_name);
        DBMS_OUTPUT.PUT_LINE('숙소 : '||vrm_loc2);
        
    END LOOP;
    CLOSE reserveinfo_cursor;
END;

EXEC UP_RESERVE('RS1');

--------------------------------------------------------------------------------
--13-2.예약 세부정보 조회
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
        DBMS_OUTPUT.PUT_LINE('게스트 : '||vhuman||'명');
        DBMS_OUTPUT.PUT_LINE('예약 번호 : '||vres_code);
        DBMS_OUTPUT.PUT_LINE('환불 정책 : '||vref_policy);
    END LOOP;
    CLOSE detailreserve_cursor;
END;

EXEC UP_DETAILRESERVE('RS1');

--------------------------------------------------------------------------------
--예약 SEQUENCE 생성
CREATE SEQUENCE seq_reserve
START WITH 53
NOCYCLE
NOCACHE;

--트리거(예약은 예약이 없는 날에만 예약이 가능하며 총인원은 최대인원을 넘을수 없고 반려동물은 최대반려동물을 넘을 수 없다) 
CREATE OR REPLACE TRIGGER ut_INSUDTreserveB
BEFORE INSERT OR UPDATE ON reserve
FOR EACH ROW
DECLARE
    CURSOR insreserve_cursor IS(
                                SELECT ci_date,co_date
                                FROM reserve
                                WHERE res_status = '예정된 여행' AND rm_code = :NEW.rm_code
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
    --예약하려는 날짜에 중복날짜가 있는지 확인
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
        RAISE_APPLICATION_ERROR(-20121,'해당날짜에 이미 예약이 있습니다.');
    WHEN all_human_exception   THEN
        RAISE_APPLICATION_ERROR(-20122,'인원이 최대수용인원을 초과했습니다.');
    WHEN all_pet_exception   THEN
        RAISE_APPLICATION_ERROR(-20123,'반려동물이 최대수용반려동물을 초과했습니다.');
END;

--------------------------------------------------------------------------------
--14.환불 정보 조회
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
                                SELECT TO_CHAR(ci_date,'YYYY"년"MM"월"DD"일"(DY)') ,TO_CHAR(co_date,'YYYY"년"MM"월"DD"일"(DY)')
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
        DBMS_OUTPUT.PUT_LINE(vrm_name||'에서 '||valldays||'박');
        DBMS_OUTPUT.PUT_LINE(vci||' -> '||vco);
        DBMS_OUTPUT.PUT_LINE(vspace||', 침대 '||vbed||'개 , 게스트 '||vperson||'명');
        DBMS_OUTPUT.PUT_LINE('호스트 : '||vmem_name);
        DBMS_OUTPUT.PUT_LINE('확인 코드(예약 코드) : '||pres_code);
        DBMS_OUTPUT.PUT_LINE('환불 정책 : '||vref_policy);
        DBMS_OUTPUT.PUT_LINE('-------------------------');
        DBMS_OUTPUT.PUT_LINE('요금내역');
        DBMS_OUTPUT.PUT_LINE('예약 상태 : '||vres_status);
        DBMS_OUTPUT.PUT_LINE('총결제 금액 : '||vtot_cost);
        DBMS_OUTPUT.PUT_LINE('환불금액 : '||vref_cost);
        DBMS_OUTPUT.PUT_LINE('-------------------------');
        DBMS_OUTPUT.PUT_LINE('카드 번호 : '||vcardnum);
    END LOOP;
    CLOSE payinfo_cursor;
END;

EXEC up_refund('RS4');

--------------------------------------------------------------------------------
--환불 SEQUENCE 생성
CREATE SEQUENCE seq_refund
START WITH 6
NOCYCLE
NOCACHE;

--트리거 (환불은 결제정보에 예약번호가 있어야 환불이 가능하다.)
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
        RAISE_APPLICATION_ERROR(-20021,'결제를 하지않았으므로 환불이 불가능 합니다.');
END;

--예약번호를 받아 환불금액 계산하는 함수 uf_refundCost(예약번호)
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
    
    IF vref_policy = '유연' THEN
        IF vci-vrequestdate >=1    THEN
            vref_cost := vtot_cost;
        ELSE
            vref_cost := 0;
        END IF;
    ELSIF vref_policy = '일반'  THEN
        IF vci-vrequestdate >=5 THEN
            vref_cost := vtot_cost;
        ELSIF vci-vrequestdate BETWEEN 1 AND 4 THEN
            vref_cost := vtot_cost*0.5;
        ELSE
            vref_cost := 0;
        END IF;
    ELSIF vref_policy = '비교적엄격'  THEN
        IF vci-vrequestdate >=30 THEN
            vref_cost := vtot_cost;
        ELSIF vrequestdate-vres_date<2 AND vci-vrequestdate >=14    THEN
            vref_cost := vtot_cost;
        ELSIF vci-vrequestdate BETWEEN 7 AND 30  THEN
            vref_cost := vtot_cost*0.5;
        ELSE
            vref_cost := 0;
        END IF;
    ELSIF vref_policy = '엄격'  THEN
        IF vrequestdate-vres_date<2 AND vci-vrequestdate >=14    THEN
            vref_cost := vtot_cost;
        ELSIF vci-vrequestdate BETWEEN 7 AND 30  THEN
            vref_cost := vtot_cost*0.5;
        ELSE
            vref_cost := 0;
        END IF;
    ELSIF vref_policy = '매우엄격30일'  THEN
        IF vci-vrequestdate >= 30 THEN
            vref_cost := vtot_cost*0.5;
        ELSE
            vref_cost := 0;
        END IF;
    ELSIF vref_policy = '매우엄격60일'  THEN
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
        RAISE_APPLICATION_ERROR(-20001,'숙소의 환불정책이 잘 못 되어있습니다.');
END;

--15.환불 추가
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
        RAISE_APPLICATION_ERROR(-20011,'환불 사유를 입력해 주세요.');
    WHEN rm_code_exception   THEN
        RAISE_APPLICATION_ERROR(-20012,'숙소코드를 입력해 주세요.');
    WHEN res_code_exception   THEN
        RAISE_APPLICATION_ERROR(-20013,'예약코드를 입력해 주세요.');
END;

--트리거 (환불이 추가한 뒤에는 예약의 예약상태가 취소한 여행으로 변경되어야 한다)
CREATE OR REPLACE TRIGGER ut_INSrefundA
AFTER INSERT ON refund
FOR EACH ROW
BEGIN
    UPDATE reserve
    SET res_status = '취소된 여행'
    WHERE res_code=:NEW.res_code;
END;

--------------------------------------------------------------------------------
-- 예약 전 체크 코드
CREATE OR REPLACE TRIGGER ut_INSUDTreserveB
BEFORE INSERT OR UPDATE ON reserve
FOR EACH ROW
DECLARE
    CURSOR insreserve_cursor IS(
                                SELECT ci_date,co_date
                                FROM reserve
                                WHERE res_status = '예정된 여행' AND rm_code = :NEW.rm_code
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
        RAISE_APPLICATION_ERROR( -20001, '해당날짜에 이미 예약이 있습니다.' );
    WHEN all_human_exception THEN
        RAISE_APPLICATION_ERROR( -20002, '인원이 최대수용인원을 초과했습니다.' );
    WHEN all_pet_exception THEN
        RAISE_APPLICATION_ERROR( -20003, '반려동물이 최대수용반려동물을 초과했습니다.' );
END;

-- 추가요금 계산 함수
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
    -- 기본요금 설정
    vtotal_price := pprice;
    
    -- 인원
    vperson := padult + pchild;
    
    -- 추가요금코드, 추가요금기준, 추가금액
    FOR vrow IN vcursor
    LOOP
        vfee_code := vrow.fee_code;
        vfee_basis := vrow.fee_basis;
        vfee_cost := vrow.fee_cost;
    END LOOP;
    
    -- 추가요금 산정
    -- 주말요금 적용
    IF vfee_code = 'ET4' AND vfee_cost != 0 THEN
        -- 단순 주말요금
        vweekend_price := pprice + vfee_cost;
        
        -- 기간동안 평일 일수 구하기
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
        
        -- 기간동안 주말 일수 구하기
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
        
        -- 최종 주말요금 산정
        vtotal_price := ( pprice * vdays_count + vweekend_price * vweekend_count ) / ( vdays_count + vweekend_count );
        
        IF vfee_code = 'ET2' AND vfee_basis > 0 AND vfee_cost != 0 THEN
            vtotal_price := vtotal_price + vfee_cost;
        END IF;
            
        IF vfee_code = 'ET3' AND vperson > vfee_basis AND vfee_cost != 0 THEN
            vtotal_price := vtotal_price + vfee_cost * ( vperson - vfee_basis );
        END IF;
        
    -- 주말요금 적용 X
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

-- 최고할인율 계산 함수
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

    -- 할인코드, 할인기준, 할인율
    FOR vdcrow IN vdccursor
    LOOP
        vdc_code := vdcrow.dc_code;
        vdc_basis := vdcrow.dc_basis;
        vrate := vdcrow.rate;
    END LOOP;

    -- 주간할인
    IF vdc_code = 'DC1' AND vnight >= vdc_basis AND vrate != 0 AND vrate IS NOT NULL THEN
        vweek_rate := vrate / 100;
    END IF;
    
    -- 월간할인
    IF vdc_code = 'DC2' AND vnight >= vdc_basis AND vrate != 0 AND vrate IS NOT NULL THEN
        vmonth_rate := vrate / 100;
    END IF;
    
    -- 조기예약할인
    IF vdc_code = 'DC3' AND MONTHS_BETWEEN( pci_date, SYSDATE ) >= vdc_basis AND vrate != 0 AND vrate IS NOT NULL THEN
        vearly_rate := vrate / 100;
    END IF;
    
    -- 막바지할인
    IF vdc_code = 'DC4' AND pci_date - SYSDATE <= vdc_basis AND vrate != 0 AND vrate IS NOT NULL THEN
        vlast_rate := vrate / 100;
    END IF;
    
    vmax_rate := GREATEST( vweek_rate, vmonth_rate, vearly_rate, vlast_rate );
    
    RETURN( vmax_rate );
    
-- EXCEPTION
END;

--------------------------------------------------------------------------------
-- 예약 기본키 시퀀스
CREATE SEQUENCE seq_res_code
    INCREMENT BY 1
    START WITH 100
    NOMAXVALUE
    NOMINVALUE
    NOCYCLE
    NOCACHE;

--16.예약 삽입 프로시저
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
    -- 기본요금
    SELECT price INTO vprice
    FROM room
    WHERE rm_code = prm_code;
    
    -- 기본요금 설정
    vtotal_price := vprice;
    
    -- 추가요금 산정
    vtotal_price := vtotal_price + uf_calc_fee( vprice, pci_date, pco_date, padult, pchild, pinfant, ppet, prm_code );

    -- 박수 구하기
    vnight := pco_date - pci_date;

    -- 계산금액에 박수 곱하기
    vtotal_price := vtotal_price * vnight;
    
    -- 할인율 산정
    vmax_rate := uf_calc_dc( pci_date, pco_date, prm_code );
    
    -- 할인 적용
    vtotal_price := vtotal_price * NVL( vmax_rate, 1 );
    
    -- 추가요금코드, 추가요금기준, 추가금액
    FOR vrow IN vcursor
    LOOP
        vfee_code := vrow.fee_code;
        vfee_basis := vrow.fee_basis;
        vfee_cost := vrow.fee_cost;
    END LOOP;
    
    -- 청소비 산정
    IF vfee_code = 'ET1' AND vfee_cost != 0 THEN
        vtotal_price := vtotal_price + vfee_cost;
    END IF;
    
    -- 전체요금 반올림
    vtotal_price := ROUND( vtotal_price );

    INSERT INTO reserve
        VALUES( 'RS' || seq_res_code.NEXTVAL, SYSDATE, pci_date, pco_date, '예정된 여행', NVL( padult, 0 )
                    , NVL( pchild, 0 ), NVL( pinfant, 0 ), NVL( ppet, 0 ), vtotal_price, prm_code, pmem_code, null );

    COMMIT;
    
    -- 출력
    DBMS_OUTPUT.PUT_LINE( TO_CHAR( vtotal_price / vnight, 'L999,999,999' ) || ' / 박' );
    DBMS_OUTPUT.PUT_LINE( '체크인' || '    |   ' || '체크아웃' );
    DBMS_OUTPUT.PUT_LINE( pci_date || '     ' || pco_date );
    DBMS_OUTPUT.PUT_LINE( '게스트 ' || ( padult + pchild ) || '명' || ', ' || '유아 ' || pinfant || '명' || ', ' || '반려동물 ' || ppet || '마리' );
    DBMS_OUTPUT.PUT_LINE( TO_CHAR( vtotal_price / vnight, 'L999,999,999' ) || ' X ' || vnight || '박' || TO_CHAR( vtotal_price, 'L999,999,999' ) );
    DBMS_OUTPUT.PUT_LINE( '-----------------------------------' );
    DBMS_OUTPUT.PUT_LINE( '총 합계' || TO_CHAR( vtotal_price, 'L999,999,999' ) );

-- EXCEPTION
END;
--------------------------------------------------------------------------------
--17.예약 수정
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
    -- 기초 정보 가져오기
    SELECT ci_date, co_date, adult, child, infant, pet, price, a.rm_code
        INTO vci_date, vco_date, vadult, vchild, vinfant, vpet, vprice, vrm_code
    FROM reserve a JOIN room b ON a.rm_code = b.rm_code
    WHERE res_code = pres_code;
    
    -- 기본요금
    vtotal_price := vprice;
    
    -- 추가요금
    vtotal_price := vtotal_price + uf_calc_fee( vprice, vci_date, vco_date, vadult, vchild, vinfant, vpet, vrm_code );
    
    -- 박수
    vnight := vco_date - vci_date; 
    
    -- 곱하기
    vtotal_price := vtotal_price * vnight;
    
    -- 할인율
    vmax_rate := uf_calc_dc( vci_date, vco_date, vrm_code );
    
    -- 할인 적용
    vtotal_price := vtotal_price * NVL( vmax_rate, 1 );
    
    -- 추가요금코드, 추가요금기준, 추가금액
    FOR vrow IN vcursor
    LOOP
        vfee_code := vrow.fee_code;
        vfee_basis := vrow.fee_basis;
        vfee_cost := vrow.fee_cost;
    END LOOP;
    
    -- 청소비 산정
    IF vfee_code = 'ET1' AND vfee_cost != 0 THEN
        vtotal_price := vtotal_price + vfee_cost;
    END IF;
    
    -- 전체요금 반올림
    vtotal_price := ROUND( vtotal_price );
    
    -- 반영
    UPDATE reserve
    SET tot_cost = vtotal_price
    WHERE res_code = pres_code;
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE( '예약이 수정되었습니다.' );
-- EXCEPTION
END;
--------------------------------------------------------------------------------
--18.예약 삭제
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
        
        DBMS_OUTPUT.PUT_LINE( '예약이 취소되었습니다.' );
    END IF;
    
    COMMIT;
    
EXCEPTION
    WHEN v_no_res_cancel THEN
        RAISE_APPLICATION_ERROR( -20022, '환불을 해주십시오' );
END;
--------------------------------------------------------------------------------
