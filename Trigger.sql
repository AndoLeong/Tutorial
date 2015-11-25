Select min_salary,max_salary
From Jobs
where jobs.id=New.jobs.id

---------------------------------------------------
---------------------------------------------------

CREATE TRIGGER verif_Salaire 
Before Insert OR Update of Salary On Employes
Referencing 
New Row As ligneApres
For each row 
Declare 
sal_min number,
sal_max number

Begin 
Select min_salary , max_salary into sal_min,sal_max from Jobs
where jobs.id=ligneApres.jobs.id;
if (ligneApres.Salary<min_salary OR ligneApres.sal_max>max_salary)
	Raise Application Error('')
endIf

---------------------------------------------------------------
---ou bien on fait comme cela ---------------------------------
---------------------------------------------------------------

If (ligneApres.Salary<min_salary)
	ligneApres.Salary=min_salary
endIf
If(ligneApres.Salary>sal_max)
	ligneApres.Salary=max_salary
endIf
End 
--------------------------------------------------------
----------on ne peut pas modifier la localisation ------
--on empeche , c'est un before , on empeche dans -------
--tout les cas , qui touchent de la ville :-------------
--------------------------------------------------------

CREATE TRIGGER verif_city
Before Update of city on localisations 


Begin 
	RaiseApplicationError('')
End
--------------------------------------------------------
------Version 2-----------------------------------------
--------------------------------------------------------
CREATE TRIGGER verif_city_non_opt
Before Update on localisations 
Referencing 
	New Row as ligneApres
	old Row as ligneAvant
For each row
Begin 

	If (ligneApres.city <>ligneAvant.city)
		RaiseApplicationError('')
	endIf
	--doit verifier chacune des valeurs donc For Each row 
End

--------------------------------------------------------
-- Ajout de nb Employe dans le tableau departement -----
-- initialiser a 0 , garder cette information a jour ---
-- en utilisant des TRIGGER-----------------------------
--------------------------------------------------------
CREATE TRIGGER IEVerifNbr
--rien a empeche la mise a jour apres donc 
After Insert on Employe
Referencing
	New Row As ligneApres

For Each Row 
	Begin 
		Update Departement
		set NbrEmp=NbRep+1
		where ligneApres.Departement_ID=Departement.Departement_ID
	End

--------------------------------------------------------
--------------------------------------------------------
--------------------------------------------------------
CREATE TRIGGER DEVerfiNBR
After Delete On Employe
Referencing 
	old row ligneAvant
For Each Row
Begin 
	Update Departement
	set NB_Empl=NB_Empl-1
	where departement.Departement_ID=ligneAvant.Departement_ID
End

--------------------------------------------------------
--------------------------------------------------------
--------------------------------------------------------
CREATE TRIGGER UEVerifNbr
After Update of Departement_ID on Departement
Referencing 
	New Row as ligneApres
	old Row as ligneAvant
For each row 
Begin 
On Update Departement set NbrEmp=NbrEmp+1
where Departement_ID=ligneApres.Departement_ID
End
--------------------------------------------------------
--------------------------------------------------------
--------------------------------------------------------
CREATE TRIGGER IDVerifNBR
After Insert on Departement 
Referencing 
New Row As ligneApres
For Each Row 
Begin 
	Update Departement
	set NbrEmp=0
	where Departement_ID=ligneApres.Departement_ID
End

--------------------------------------------------------
-- En 2 Triggers ---------------------------------------
--------------------------------------------------------
CREATE TRIGGER IJH_Verif
After Insert on job_history 
Referencing
	New Row As ligneApres
For each Row 
Begin 
Update Employe set 
nbrJH=nbrJH+1
where Employe.id = ligneApres.employe.id
End

--OR
CREATE TRIGGER IJH_Verif
After Delete on job_history 
Referencing
	old Row As ligneAvant
For each Row 
Begin 
Update Employe set 
nbrJH=nbrJH-1
where Employe.id = ligneAvant.employe.id
End


--------------------------------------------------------
--En un seul trigger -----------------------------------
--------------------------------------------------------



--------------------------------------------------------
--ne permettre que la modification d'un trigger dans----
--la table job -----------------------------------------
--------------------------------------------------------
CREATE TRIGGER VJverif
Before Update of Jobs_Id,Jobs_Title on Jobs  

Begin 
	RaiseApplicationError('')
End

--------------------------------------------------------
--La date d'embauche doit etre superieur a la date -----
--d'aujourd'hui ----------------------------------------
--------------------------------------------------------

--l'action est la meme 
CREATE TRIGGER IVEVerif 
Before Insert or update of hire_Date on Employes
Referencing 
	New Row as ligneApres
For each Row 
Begin 
	if (ligneApres.hire_Date<Select SynDate From Dual )
		RaiseApplicationError('')
	endIf
End



--------------------------------------------------------
--On verfifie il y a un seul manageur par departement --
--------------------------------------------------------
----->Ne marche pas ------------------------------------
--------------------------------------------------------



--------------------------------------------------------
---Verifions si un employe a plus d'un gestionnaire ----
-- Mais son Id est associe a un seul manageur donc -----
-- Il ne peut pas exister ------------------------------
--------------------------------------------------------


------------------------------------------------------------
--Une contrainte : pas plus de 2 localisations par departement -
------------------------------------------------------------

CREATE TRIGGER IDVerif 
Before Insert on Departement
Referencing 
	New Row as ligneApres
	Begin
		If (2<Select count(*))from Departement,localisations where localisations.location_ID=Departement.location_ID And Departement.departmenet_name=ligneApres.departmenet_name)
		RaiseApplicationError('')
		endIf
	End

