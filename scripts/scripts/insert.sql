BEGIN    
FOR i IN 1 .. 50000
LOOP
     insert into student values  (roll_seq.nextval,'Alim','Mumbra',9326889771);

END LOOP;
    
END;    
/  

