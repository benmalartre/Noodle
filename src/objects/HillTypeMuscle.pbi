DeclareModule HillTypeMuscle
  ; --------------------------------------------------------------------
  ; Parallel elastic element
  ; --------------------------------------------------------------------
  Structure PEE
    l_0.f       ; rest normalized To ce opt length (Guenther et al., 2007)
    v.f         ; exponent of F_PEE (Moerl et al., 2012)
    F.f         ; force of PEE If l_CE is stretched To deltaWlimb_des (Moerl et al., 2012)
    K.f         ; factor of non-linearity in F_PEE (Guenther et al., 2007)
  EndStructure
  
  ; --------------------------------------------------------------------
  ; Serial elastic element
  ; The series elastic element Values are derived from Gunther et al 2007 And  Haeufle et al 2014
  ;
  ; Parameters
  ; ----------
  ; l_0: float (0.172) rest l in [m] (Kistemaker et al., 2006)
  ; DeltaF_0: float (568.0) both force at the transition And force increase in the linear part in [N] (~ 40% of maximal isometric muscle force)
  ; DeltaU_nll: float (0.0425) relative stretch at non-lin/lin transition (Moerl et al., 2012)
  ; DeltaU_l: float (0.017) relative additional stretch in the linear part providing a force increase of deltaF_SEE0 (Moerl, 2012)
  ; --------------------------------------------------------------------
  Structure SEE
    l_0.f
    DeltaF_0.f
    DeltaU_nll.f 
    DeltaU_l.f 
    l_nll.f
    v.f
    Kl.f
    Knl.f
  EndStructure
  
  ; --------------------------------------------------------------------
  ; Serial damping element
  ; --------------------------------------------------------------------
  Structure SDE
    D.f       ; dimensionless factor To scale d_max (Moerl et al., 2012)
    R.f       ; min damp normalised To d_max (Moerl et al., 2012)
    D_max.f   ; Max damp value in [Ns/m] (Moerl et al., 2012)
  EndStructure
  
  
  ; --------------------------------------------------------------------
  ; Contractile element
  ; F_max: max force of extensor (Kistemaker et al., 2006), Newtons
  ; l_opt: optimal length of extensor (Kistemaker et al., 2006), meters
  ; DeltaW_des: width of normalized bell curve in descending limb (Moerl et al., 2012)
  ; v_des: exponent For descending limb (Moerl et al., 2012)
  ; --------------------------------------------------------------------
  Structure CE
    l_init.f
    l.f
    F_max.f
    l_opt.f
    DeltaW_des.f
    DeltaW_asc.f
    v.f
    v_des.f
    v_asc.f
    a_rel0.f
    b_rel0.f
  EndStructure
  
  ; --------------------------------------------------------------------
  ; Hill-Type Muscle
  ; --------------------------------------------------------------------
  Structure Muscle
    l_init.f        ; initial length
    l.f             ; current length
    q_init.f        ; initial q
    q.f             ; current q
    dt.f            ; delta time in seconds
    v.f             ; prescribed, muscle velocity starts at rest
    
    ce.CE           ; contractile element
    pee.PEE         ; parallel elastic elemnt
    see.SEE         ; serial elastic element
    sde.SDE         ; serial damping element
    
    f_see.f         ; serial elastic elemnt force
    f_ce.f          ; contractile element force
    f_pee.f         ; parallel elastic element force
  EndStructure

  
  Declare PEEInit(*muscle.Muscle)
  Declare.f PEEForce(*muscle.Muscle, length.f)
  
  Declare SEEInit(*muscle.Muscle, l_0=0.172, DeltaF_0=568.0, DeltaU_nll=0.0425, DeltaU_l=0.017)
  Declare SEECalculateDerivedValues(*see.SEE)
  Declare.f SEEForce(*muscle.Muscle, length.f)
  
  Declare SDEInit(*muscle.Muscle)
  Declare.f SDEForce(*muscle.Muscle, length.f, q.f)
  
  Declare CEInit(*muscle.Muscle)
  Declare.f CEForce(*muscle.Muscle)
  
EndDeclareModule


Module HillTypeMuscle
  ; --------------------------------------------------------------------
  ; Parallel elastic element
  ; --------------------------------------------------------------------
  Procedure PEEInit(*muscle.Muscle)
    Protected *pee.PEE = *muscle\pee
    Protected *ce.CE = *muscle\ce
    *pee\l_0 = 0.9 * *ce\l_opt
    *pee\v = 2.5
    *pee\F = 2.0
    *pee\K = *pee\F * (*ce\F_max / (*ce\l_opt*(*ce\DeltaW_des + 1 - *pee\l_0) ) * *pee\v)
  EndProcedure
  
  Procedure.f PEEForce(*muscle.Muscle, length.f)
    Protected *pee.PEE = *muscle\pee
    If length >= *pee\l_0:
      ProcedureReturn Pow(*pee\K*(length-*pee\l_0), *pee\v)
    Else
      ProcedureReturn 0
    EndIf
  EndProcedure
          
  ; --------------------------------------------------------------------
  ; Serial elastic element
  ; --------------------------------------------------------------------
  Procedure SEEInit(*muscle.Muscle, l_0=0.172, DeltaF_0=568.0, DeltaU_nll=0.0425, DeltaU_l=0.017)
    Protected *see.SEE = *muscle\see
    *see\l_0 = l_0
    *see\DeltaF_0 =  DeltaF_0
    *see\DeltaU_nll = DeltaU_nll 
    *see\DeltaU_l = DeltaU_l 
    SEECalculateDerivedValues(*see)
  EndProcedure
      
  Procedure SEECalculateDerivedValues(*see.SEE)
    ; Update the derived values, allows setting upstream parameters
    ; And reinitializing With new generative values
    With *see
      \l_nll = (1 + \DeltaU_nll)*\l_0                  ; length of non-linear region
      \v     = \DeltaU_nll / \DeltaU_l                 ; exponent of non-lin region
      \Knl   = Pow(\DeltaF_0 / (\DeltaU_nll*\l_0), v)  ; spring in non-lin
      \Kl    = \DeltaF_0 / (\DeltaU_l*\l_0)            ; spring in lin
    EndWith
  EndProcedure
  
  Procedure.f SSEForce(*muscle.Muscle, length.f)
    ; Force of the serial elastic element
    ; Parameters
    ; length : length of the serial elastic element
    Protected *see.SEE = *muscle\see
    If (length>*see\l_0) And (length<*see\l_nll)                ; non-linear part
      ProcedureReturn Pow(*see\Knl*((length-*see\l_0), *see\v))
    ElseIf length>=*see\l_nll                                   ; linear part
      ProcedureReturn *see\DeltaF_0+*see\Kl*(length-*see\l_nll)
    Else                                                        ; slack length
      ProcedureReturn 0
    EndIf
  EndProcedure
 
  ; --------------------------------------------------------------------
  ; Serial damping element
  ; --------------------------------------------------------------------
  Procedure SDEInit(*muscle.Muscle)
    Protected *sde.SDE = *muscle\sde
    *sde\D = 0.3
    *sde\R  = 0.01
    With *muscle\ce
      *sde\D_max = *sde\D * (\F_max * \a_rel0) / (\l_opt * \b_rel0)
    EndWith
  EndProcedure
  
  Procedure.f SDEForce(*muscle.Muscle)
    Protected *sde.SDE =  *muscle\sde
    With *sde
      Protected ce_length.f = \ce\l
      Protected q.f = \q
      Protected f_ce.f = CEForce(\ce, q)
      Protected f_max.f = \ce\F_max
      Protected f_pee.f = PEEForce(\pee, ce_length)
      Protected v_mus.f = \v 
      Protected v_ce = \ce\v
    EndWith
    ProcedureReturn (*sde\D_max * ((1-*sde\R)*(f_ce + f_pee)/f_max + *sde\R) * (v_mus - v_ce))
  EndProcedure
  
  ; --------------------------------------------------------------------
  ; Contractile element
  ; --------------------------------------------------------------------
  Procedure CEInit(*muscle.Muscle)
    Protected *ce.CE = *muscle\ce
    *ce\l_init = -1 
    *ce\l = *ce\l_init
    *ce\muscle = *muscle
    *ce\F_max = 1420.0
    *ce\l_opt = 0.092
    *ce\DeltaW_des = 0.35
    *ce\DeltaW_asc = 0.35
    *ce\v = 0.0
    *ce\v_des = 1.5
    *ce\v_asc = 3.0
    *ce\a_rel0 = 0.25
    *ce\b_rel0 = 0.25
  EndProcedure
  
  Procedure CEIsoForce(*muscle.Muscle, length.f)
    ; Isometric force (Force length relation) via Guenther et al. 2007
    ; Expressed As a normalized force (0,1)
    Protected *ce.CE = *muscle\ce 
    Protected DeltaW.f, v.f
    If length >= *ce\l_opt    ; descending limb
      DeltaW = *ce\DeltaW_des
      v = *ce\v_des
    Else:                     ; ascending limb
      DeltaW = *ce\DeltaW_asc
      v = *ce\v_asc
    EndIf
    
    ProcedureReturn Exp(-(Pow(Abs(((length / *ce\l_opt) - 1) /DeltaW)), v)
  EndProcedure
  
  Procedure.f CEARel(*ce.CE, length.f, q.f)
    Protected a_len.f
    If length < *ce\l_opt   ; ascending limb
      a_len = 1.0
    Else
      a_len = CEIsoForce(*ce, length)
    EndIf
    Protected a_q.f = 1.0/4.0*(1.0+3.0*q)
    ProcedureReturn *ce\a_rel0 * a_len * a_q
  EndProcedure
  
  Procedure.f CEBRel(*ce.CE, length.f, q.f)
     Protected b_len.f = 1.0
     Protected b_q.f = 1.0/7.0*(3.0+4.0*q)
     ProcedureReturn *ce\b_rel0 * b_len * b_q
  EndProcedure
  
  Procedure.f CEForce(*ce.CE, length.f, q.f)
    ; Force during concentric contractions
    Protected a.f = CEARel(*ce, length, q)
    Protected b.f = CEBRel(*ce, length, q)
    ProcedureReturn *ce\F_max * ((q * CEIsoForce(length) + a) / (1 - *ce\v/(b* *ce\l_opt)) - a)
  EndProcedure
  
  Procedure.f CEUpdateVelocity(*muscle.Muscle, muscle_length.f, q.f)
    Protected *ce.CE = *muscle\ce
    ; Compute the velocity of the contractile element
    ; Values of the CE
    Protected f_isom.f = CEIsoForce(*ce, *ce\l)
    Protected f_max.f = *ce\F_max
    Protected l_opt.f = *ce\l_opt
    Protected a_rel.f = CEARel(*ce, muscle_length, q)
    Protected b_rel.f = CEBRel(*ce, muscle_length, q)
    
    ; SEE
    Protected see_length.f = muscle_length - *ce\l
    Protected f_see.f = SEEForce(*muscle, *ce\see_length)
    
    ; PEE
    Protected f_pee.f = PEEForce(*muscle, *ce\l)
    
    ; SDE
    Protected r_sde.f = *muscle\sde\R
    Protected d_max_sde.f = *muscle\sde\D_max
    
    ; Muscle
    Protected v_mus = *muscle\v
    
    ; Calculate f_st (f_static + f_trans)
    Protected f_st.f = 0.0
    ; Coefficients 
    Protected alpha.f = (d_max_sde * (f_max * (r_sde * (1 + a_rel) - a_rel) - (f_pee - f_st) * (r_sde - 1)))
    Protected beta.f = (b_rel * d_max_sde * l_opt * (f_pee - f_st) * (r_sde - 1) - 
            a_rel * f_max**2 + 
            f_max * (f_pee - f_see - f_st + 
                     b_rel * d_max_sde * l_opt * 
                     (q * f_isom * (r_sde - 1) - r_sde)) - 
             alpha * v_mus)
    Protected chi.f = (-b_rel * l_opt * 
           (f_max * (f_pee - f_see - f_st) + 
            d_max_sde * v_mus * (f_st + f_pee * (r_sde - 1) - (f_max + f_st) * r_sde) + 
            q * f_isom * f_max * (f_max + d_max_sde * v_mus * (r_sde - 1))))
    ; Velocity
    *muscle\ce\v = (-beta - Sqrt(Pow(beta, 2) - 4 * alpha * chi)) / (2*alpha)
    ProcedureReturn *muscle\ce\v
    
  EndProcedure
  
  Procedure MuscleInit(*muscle.Muscle, initial_length=0.264, initial_q=0, dt=0.001)
    *muscle\l_init = initial_length
    *muscle\l = initial_length
    *muscle\q_init = initial_q
    *muscle\q = initial_q
    *muscle\dt = dt                    ; in seconds
    *muscle\v = 0.0
    CEInit(*muscle)
    PEEInit(*muscle)
    SEEInit(*muscle)
    SDEInit(*muscle)
    *muscle\ce\l_init = MuscleEquilibriumContractileElementLength(*muscle, *muscle\q)
    *muscle\ce\l = *muscle\ce\l_init
  EndProcedure
  
  Procedure MuscleStaticForces(*muscle.Muscle)
    ; Use To find initial lengths
    ; Parse passed values To stored If blank
    Protected ce_length.f = *muscle\ce\l
    Protected muscle_length.f = *muscle\l
    Protected q.= *muscle\q
    ; Calc forces
    Protected see_length.f = muscle_length - ce_length
    *muscle\f_see = SEEForce(*muscle, see_length)
    *muscle\f_ce = q * CEIsoForce(*muscle, ce_length) * *muscle\ce\F_max
    *muscle\f_pee = PEEForce(*muscle, ce_length)
  EndProcedure
  
  Procedure MuscleResidualForces(*muscle.Muscle)
    ; Use to find initial lengths
    MuscleStaticForces(*muscle)
    Protected residual.f = *muscle\f_see - *muscle\f_ce - *muscle\f_pee
    ProcedureReturn residual
  EndProcedure
  
  Procedure MuscleTension(
    ; The tension felt at the muscle ends"""
    MuscleStaticForces(*muscle)
    ProcedureReturn *muscle\f_ce + *muscle\f_pee
  EndProcedure
  
  Procedure MuscleEquilibriumContractileElementLength(*muscle.Muscle, q.f)
     ; Run to figure out the equilibrium length of contractile element
     ; Finds the Static force balance length between CE, PEE, And SEE 
     ; at current muscle length And given activation level
     Protected residual_force.f = lambda l: self.residual_force(l, self.l, q)
     ;Protected ce_length_eq.f = scipy.optimize.fsolve(residual_force, 0.092)[0]
     
     ProcedureReturn ce_length_eq
   EndProcedure

;    Procedure.d f(x.d)
;   ProcedureReturn x*x*x-3*x*x+2*x
; EndProcedure
;  
; Procedure main()
;   OpenConsole()
;   Define.d StepSize= 0.001
;   Define.d Start=-1, stop=3
;   Define.d value=f(start), x=start
;   Define.i oldsign=Sign(value)
;  
;   If value=0
;     PrintN("Root found at "+StrF(start))
;   EndIf
;  
;   While x<=stop
;     value=f(x)
;     If Sign(value) <> oldsign
;       PrintN("Root found near "+StrF(x))
;     ElseIf value = 0
;       PrintN("Root found at "+StrF(x))
;     EndIf
;     oldsign=Sign(value)
;     x+StepSize
;   Wend
; EndProcedure
  
  
class Muscle:
    """ All the elements together
    Force balance is: $F_{ce} + F_{pee} = F_{see} + F_{sde}$ Or, With more
    detail:
    TODO: FIX LATEX $$F_{ce}(l_{ce}, dot_l_ce, q) + F_pee(l_ce) = 
    F_see(l_cw, l_mtu) + F_sde(l_ce, v_ce, v_mtc, q)
    """
    def __init__(self, initial_length=0.264, initial_q=0, dt=0.001):
        """Default value for initial length is 0.092+0.172, the sum of the 
        CE optimal length And the SEE rest length.
        """
        # Set own values
        self.l_init = initial_length
        self.l = initial_length
        self.q_init = initial_q
        self.q = initial_q
        self.dt = dt # in seconds
        self.v = 0.0 # prescribed, muscle velocity starts at rest
        # Create elements
        self.ce = CE(self)
        self.pee = PEE(self.ce)
        self.see = SEE()
        self.sde = SDE(self)
        # Initialize element lengths
        self.ce.l_init = self.equilibrium_ce_length(self.q)
        self.ce.l = self.ce.l_init 

    def equilibrium_ce_length(self, q):
        """Run to figure out the equilibrium length of contractile element
        Finds the Static force balance length between CE, PEE, And SEE 
        at current muscle length And given activation level
        """
        residual_force = lambda l: self.residual_force(l, self.l, q)
        ce_length_eq = scipy.optimize.fsolve(residual_force, 0.092)[0]
        Return ce_length_eq

    def Step(self, q=None, dt=None):
        """Take a step, q is activation (0,1), dt is time in sec"""
        q = self.q If q is None Else float(q)
        self.q = q
        dt = self.dt If dt is None Else float(dt)
        self.dt = dt
        # Find CE speed
        self.ce.update_v(self.l, q)
        # Find element forces
        f_see = self.see.force(self.l - self.ce.l)
        f_sde = self.sde.force(self.ce.l, q)
        f_mtc = f_see + f_sde
        # TODO left off here. Need To validate the 1000 mass scaling factor For
        # conversion To a, Not even sure we want To Return a
        a_mtc = f_mtc / 1000.0 
        self.ce.l += self.ce.v*dt
        #return Str(self.l_MTC) + " " + Str(self.v_MTC) + " " + Str(self.v_CE) + " " + Str(self.l_CE) + " " + Str(f_mtc) + " " + Str(a_mtc)
        Return a_mtc

    def log_dict(self):
        """Log the state of the model and return as a dict"""
        d = {"ce_f":self.ce.force(),
             "ce_l":self.ce.l,
             "ce_v":self.ce.v,
             "pee_f":self.pee.force(self.ce.l),
             "pee_l":self.ce.l,  # same length As ce
             "pee_v":self.ce.v,  # thus same v
             "see_f":self.see.force(self.l - self.ce.l),
             "see_l":self.l - self.ce.l,
             "see_v":self.v-self.ce.v,  # muscle vel minus ce vel
             "sde_f":self.sde.force(),
             "sde_l":self.l - self.ce.l,  # same As see
             "sde_v":self.v-self.ce.v}  # same As see
        Return d
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 341
; FirstLine = 316
; Folding = ----
; EnableXP