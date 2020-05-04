//
//  GameViewController.swift
//  Massicot
//
//  Created by vaneffen on 13/06/2015.
//  Copyright (c) 2015 EMG. All rights reserved.
//


import UIKit
import SpriteKit
import StoreKit
import CoreFoundation
import AVFoundation



class GameViewController: UIViewController, SwiftrisDelegate, UIGestureRecognizerDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    var scene: GameScene!
    var swiftris:Swiftris!
    var panPointReference:CGPoint?
    var choixFait = "choix"
    var compteur = 0
    var tempsMis = 0
    var tempsPartie = 1
    var tempsAttente = 20
    var jaugeBoost = 0
    var tempsBoost = 0
    var boosterMode = false
    var modeJeu = 0
    var gainKado = 0
    var gainArgent = 0
    var gainCumule = 0
    var dejaDone = 0
    var niveauAtteint = 1
    var mondeActuel = 1
    let globalBouton = UIButton(type: UIButtonType.System)
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var grosPointillesv = UIImageView(frame: CGRectMake(155, 42, 10, 193));
    var grosPointillesh = UIImageView(frame: CGRectMake(63, 135, 193, 10));
    var massiHautgauche = UIImageView(frame: CGRectMake(70, 50, 90, 90));
    var massiHautdroite = UIImageView(frame: CGRectMake(160, 50, 90, 90));
    var massiBasgauche = UIImageView(frame: CGRectMake(70, 140, 90, 90));
    var massiBasdroite = UIImageView(frame: CGRectMake(160, 140, 90, 90));
    var modePoints = 0
    var lotEpisode = "minenew"
    var melomaneOuPas = 0
    var dansLeJeu = 0
    var persoChoisi = 0
    var voitureChoisie = 0
    var maisonChoisie = 0
    var piscineChoisie = 0
    var lunettesChoisies = 0
    var nombreDefaites = 0
    var nombreMatches = 0
    var medaillesObtenues = 0
    var scoreMoyen = 910
    var scoreProvisoire = 0
    var onceRefill = 0
    var influTotale:Double = 0
    
    var audioPlayer = AVAudioPlayer()
    var audioJeu = AVAudioPlayer()
    var isPlaying = false
    
    var dateDefaite: CFAbsoluteTime!
    
    var listeProduits = [SKProduct]()
    var achatEnCours = SKProduct()
    
    
    
    func acheterProduit() {
        var pay = SKPayment(product: achatEnCours)
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        SKPaymentQueue.defaultQueue().addPayment(pay as SKPayment)
    }
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        print("product request")
        var myProduct = response.products
        
        for product in myProduct {
            listeProduits.append(product as! SKProduct)
        }
        
        boutonContinue.enabled = true
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
        print("transactions restored")
        
        var purchasedItemIDS = []
        for transaction in queue.transactions {
            var toctoc: SKPaymentTransaction = transaction as! SKPaymentTransaction
            
            let prodID = toctoc.payment.productIdentifier as String
            
            switch prodID {
            case "com.emg.Massicot.lives":
                print("something")
            default:
                print("nothing")
            }
        }
    }
    
    func RestorePurchases() {
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }
    
    func paymentQueue4(_ queue: SKPaymentQueue!, updatedDownloads downloads: [AnyObject]!) {
        print("telecharge")
    }
    
    func paymentQueue49(_ queue: SKPaymentQueue!, removedTransactions transactions: [AnyObject]!)
    {
        print("remove trans");
    }
    
    func paymentQueue(queue: SKPaymentQueue,
        updatedTransactions transactions: [SKPaymentTransaction]) {
        print("ajoute transac")
        
        for transaction:SKPaymentTransaction in transactions {
            var trans = transaction as! SKPaymentTransaction
            print(trans.error)
            
            switch trans.transactionState {
            
            case .Purchased:
                let prodID = achatEnCours.productIdentifier as String
                switch prodID {
                case "com.emg.Massicot.lives":
                    cadreCharge.hidden = true
                    sommeilReparateur()
                case "com.emg.Massicot.littlehelp":
                    cadreCharge.hidden = true
                    petiteAide()
                case "com.emg.Massicot.extracash":
                    cadreCharge.hidden = true
                    extraArgent()
                default:
                    print("ti probleme")
                }
                queue.finishTransaction(trans)
                break;
            case .Failed:
                cadreReseau.hidden = true
                cadreCharge.hidden = true
                print("nullos")
                queue.finishTransaction(trans)
                break;
            default:
                print("default")
                break;
                
            }
        }
    }
    
    func finishTransaction(trans:SKPaymentTransaction)
    {
        print("finish trans")
        SKPaymentQueue.defaultQueue().finishTransaction(trans)
    }
    
    func petiteAide(){
        degageMenu1(cadrePresque)
        cadreNoirJeu.hidden = true
        onceRefill = 0
        if modePoints == 3 {
            compteur = 100
            let compteurFoisDeux:Int = Int((120-compteur)/2)
            compteurLabel.text = String(compteurFoisDeux)+"s"
            barreBoost.frame = CGRectMake(288, 170, 20, 26)
            swiftris.beginGame()
        } else if modePoints == 2 {
            swiftris.beginGame()
        } else {
            compteur = 25
            compteurLabel.text = String(30-compteur)
            barreBoost.frame.size.height = CGFloat(150-(compteur*5))
            barreBoost.frame.origin.y = 45+CGFloat(compteur*5)
            swiftris.beginGame()
        }
    }
    
    func sommeilReparateur(){
        print("bien dormi")
        cadreWait.hidden = true
        leMonde.hidden = false
        leMonde.alpha = 1
        cadreJeu.hidden = true
        cadreJoujou.hidden = true
        cadreNoir.hidden = true
        swiftris.level = 1
        swiftris.vies = 5
        compteur = 0
        gainCumule = 0
        tempsPartie = 0
        barreBas.hidden = true
        cadreNoirJeu.hidden = true
        viesLabel.text = "\(swiftris.vies)"
        
        let sowvie = NSUserDefaults.standardUserDefaults()
        sowvie.setInteger(swiftris.vies, forKey: "viesBanque")
        scene.stopTicking()
        
        dateDefaite = 19830
        sowvie.setDouble(dateDefaite!, forKey: "dateBanque")
        
        if isPlaying == true {
            audioJeu.stop()
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        }
    }
    
    func extraArgent(){
        print("loterie")
        swiftris.score += 3000
        scoreLabel.text = "\(swiftris.score)"
        let sovvie = NSUserDefaults.standardUserDefaults()
        sovvie.setInteger(swiftris.score, forKey: "argentBanque")
        cadreBourse.hidden = true

    }
    
    @IBOutlet weak var speedUpSommeil: UIButton!
    
    
    func speedUpBouton(sender:UIButton!){
        cadreCharge.hidden = false
        cadreCharge.alpha = 1
        cadreReseau.hidden = false
        for product in listeProduits {
            var prodID = product.productIdentifier
            if(prodID == "com.emg.Massicot.lives") {
                cadreReseau.hidden = true
                achatEnCours = product
                acheterProduit()
                break;
            }
        }
    }

    @IBOutlet weak var cadreReseau: UIView!
    
    @IBAction func boutonReseau(sender: UIButton) {
        cadreReseau.hidden = true
        cadreCharge.hidden = true
    }
    
    @IBOutlet weak var cadreBourse: UIView!
    
    @IBAction func cadreBourseNo(sender: UIButton) {
        cadreBourse.hidden = true
    }

    @IBAction func cadreBourseYes(sender: UIButton) {
        cadreCharge.hidden = false
        cadreCharge.alpha = 1
        cadreReseau.hidden = false
        for product in listeProduits {
            var prodID = product.productIdentifier
            if(prodID == "com.emg.Massicot.extracash") {
                cadreReseau.hidden = true
                achatEnCours = product
                acheterProduit()
                print("lance")
                break;
            }
        }
    }
    @IBAction func quitSommeil(sender: UIButton) {
        cadreWait.hidden = true
        leMonde.hidden = false
        leMonde.alpha = 1
        cadreJeu.hidden = true
        cadreJoujou.hidden = true
        cadreNoir.hidden = true
        swiftris.level = 1
        compteur = 0
        gainCumule = 0
        tempsPartie = 0
        barreBas.hidden = true
        cadreNoirJeu.hidden = true
        viesLabel.text = "\(swiftris.vies)"
        scene.stopTicking()
        if isPlaying == true {
            audioJeu.stop()
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        }
    }
    
    @IBOutlet weak var cadreJardin: UIView!
    
    @IBOutlet weak var cadreFleurs: UIView!
    
    func ouvreJardin(sender:UIButton!){
    }
    @IBOutlet weak var boutondefleur: UIButton!
    
    func floraison(sender:UIButton!){
        let duoTata1 = UIImage(named: "flower1.png") as UIImage?
        let duoTata2 = UIImage(named: "flower2.png") as UIImage?
        let duoTata3 = UIImage(named: "flower3.png") as UIImage?
        let duoTata5 = UIImage(named: "flower5.png") as UIImage?
        let duoTata5b = UIImage(named: "flower5b.png") as UIImage?
        let duoTata5c = UIImage(named: "flower5c.png") as UIImage?
        let nummer4 = UIImage(named: "nummer4.png") as UIImage?
        let buisson = UIImage(named: "buisson.png") as UIImage?
        switch Int(arc4random_uniform(9)) {
        case 0:
            sender.setBackgroundImage(duoTata1, forState: .Normal)
        case 1:
            sender.setBackgroundImage(duoTata2, forState: .Normal)
        case 2:
            sender.setBackgroundImage(duoTata3, forState: .Normal)
        case 3:
            sender.setBackgroundImage(duoTata5, forState: .Normal)
        case 4:
            sender.setBackgroundImage(duoTata5b, forState: .Normal)
        case 5:
            sender.setBackgroundImage(duoTata5c, forState: .Normal)
        case 6:
            sender.setBackgroundImage(nummer4, forState: .Normal)
        case 7:
            sender.setBackgroundImage(buisson, forState: .Normal)
        default:
            sender.setBackgroundImage(duoTata1, forState: .Normal)
        }
    }
    
    @IBOutlet weak var leMonde: UIScrollView!
    
    @IBOutlet weak var cadreCharge: UIImageView!
    
    @IBOutlet weak var mondeSoleil: UIButton!
    
    @IBOutlet weak var soleilUnlocked: UIImageView!
    
    @IBOutlet weak var mondeNuage: UIImageView!
    
    @IBOutlet weak var pointiV1: UIImageView!

    @IBOutlet weak var pointiV2: UIImageView!
    
    @IBOutlet weak var pointiV3: UIImageView!
    
    @IBOutlet weak var pointiH1: UIImageView!
    
    @IBOutlet weak var pointiH2: UIImageView!
    
    @IBOutlet weak var pointiH3: UIImageView!
    
    @IBOutlet weak var cadreStars: UIImageView!
    
    @IBAction func tryAgain(sender: UIButton) {
        degageMenu1(cadreLose)
        cadreNoirJeu.hidden = true
        onceRefill = 0
        if modePoints == 4 {
            barreBoost.frame = CGRectMake(288, 230, 20, 1)
            barreBoost2.frame = CGRectMake(12, 230, 20, 1)
        } else {
            barreBoost.frame = CGRectMake(288, 50, 20, 180)
        }
        if swiftris.vies < 1 {
            cadreNoir.hidden = false
            swiftris.waitGame()
            boutonGrossit(speedUpSommeil)
        } else {
            swiftris.beginGame()
        }
    }
    @IBAction func quitLose(sender: UIButton) {
        cadreLose.hidden = true
        cadreConfirm.hidden = true
        cadreWait.hidden = true
        cadreHaut.hidden = true
        leMonde.hidden = false
        leMonde.alpha = 1
        cadreJeu.hidden = true
        cadreJoujou.hidden = true
        cadreNoir.hidden = true
        swiftris.level = 1
        let sauveporte = NSUserDefaults.standardUserDefaults()
        nombreDefaites += 1
        sauveporte.setInteger(nombreDefaites, forKey: "defaitesBanque")
        compteur = 0
        gainCumule = 0
        tempsPartie = 0
        barreBas.hidden = true
        cadreNoirJeu.hidden = true
        viesLabel.text = "\(swiftris.vies)"
        scene.stopTicking()
        if isPlaying == true {
            audioJeu.stop()
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        }
        
    }
    @IBAction func leaveJeu(sender: UIButton) {
        //qd on se tire du jeu en cours
        cadreLose.hidden = true
        cadreConfirm.hidden = true
        cadreWait.hidden = true
        cadreHaut.hidden = true
        leMonde.hidden = false
        leMonde.alpha = 1
        cadreJeu.hidden = true
        cadreJoujou.hidden = true
        cadreNoir.hidden = true
        swiftris.level = 1
        let sauveporte = NSUserDefaults.standardUserDefaults()
        nombreDefaites += 1
        sauveporte.setInteger(nombreDefaites, forKey: "defaitesBanque")
        let sauveporc = NSUserDefaults.standardUserDefaults()
        swiftris.vies -= 1
        viesLabel.text = "\(swiftris.vies)"
        sauveporc.setInteger(swiftris.vies, forKey: "viesBanque")
        compteur = 0
        gainCumule = 0
        tempsPartie = 0
        barreBas.hidden = true
        cadreNoirJeu.hidden = true
        viesLabel.text = "\(swiftris.vies)"
        scene.stopTicking()
        taler1.hidden = true
        taler2.hidden = true
        taler3.hidden = true
        taler4.hidden = true
        taler5.hidden = true
        taler6.hidden = true
        taler7.hidden = true
        taler8.hidden = true
        taler9.hidden = true
        taler10.hidden = true
        if isPlaying == true {
            audioJeu.stop()
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        }
        if swiftris.vies == 0 {
            dateDefaite = CFAbsoluteTimeGetCurrent()
            sauveporc.setDouble(dateDefaite!, forKey: "dateBanque")
        }
    }
    
    @IBAction func quitLose2(sender: UIButton) {
        //concerne le cadrehaut
        cadreHaut.hidden = true
        cadreNoir.hidden = true
        if isPlaying == true {
            audioJeu.stop()
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        }
    }
    
    @IBAction func quitterJeu(sender: UIButton) {
        scene.stopTicking()
        cadreConfirm.hidden = false
        cadreNoirJeu.hidden = false
    }
    
    @IBAction func boutonReprendre(sender: UIButton) {
        scene.startTicking()
        cadreConfirm.hidden = true
        cadreNoirJeu.hidden = true
    }
    
    @IBOutlet weak var boutonMenuQuitter: UIButton!
    
    @IBOutlet weak var cadrePersos: UIView!
    
    @IBOutlet weak var cadrePersosLabel: UILabel!
    
    @IBAction func perso01(sender: UIButton) {
        cadrePersos.hidden = true
        arriveVite(cadreHistoire1)
        boutonGlisse(flecheHistoire)
        let sauvemoi = NSUserDefaults.standardUserDefaults()
        sauvemoi.setInteger(0, forKey: "persochoisi")
        persoChoisi = 0
        installerPerso() }
    @IBAction func perso02(sender: UIButton) {
        cadrePersos.hidden = true
        arriveVite(cadreHistoire1)
        boutonGlisse(flecheHistoire)
        let sauvemoi = NSUserDefaults.standardUserDefaults()
        sauvemoi.setInteger(1, forKey: "persochoisi")
        persoChoisi = 1
        installerPerso() }
    @IBAction func perso03(sender: UIButton) {
        cadrePersos.hidden = true
        arriveVite(cadreHistoire1)
        boutonGlisse(flecheHistoire)
        let sauvemoi = NSUserDefaults.standardUserDefaults()
        sauvemoi.setInteger(2, forKey: "persochoisi")
        persoChoisi = 2
        installerPerso() }
    @IBAction func perso04(sender: UIButton) {
        cadrePersos.hidden = true
        arriveVite(cadreHistoire1)
        boutonGlisse(flecheHistoire)
        let sauvemoi = NSUserDefaults.standardUserDefaults()
        sauvemoi.setInteger(3, forKey: "persochoisi")
        persoChoisi = 3
        installerPerso() }
    @IBAction func perso05(sender: UIButton) {
        cadrePersos.hidden = true
        arriveVite(cadreHistoire1)
        boutonGlisse(flecheHistoire)
        let sauvemoi = NSUserDefaults.standardUserDefaults()
        sauvemoi.setInteger(4, forKey: "persochoisi")
        persoChoisi = 4
        installerPerso() }
    @IBAction func perso06(sender: UIButton) {
        cadrePersos.hidden = true
        arriveVite(cadreHistoire1)
        boutonGlisse(flecheHistoire)
        let sauvemoi = NSUserDefaults.standardUserDefaults()
        sauvemoi.setInteger(5, forKey: "persochoisi")
        persoChoisi = 5
        installerPerso() }
    @IBAction func perso07(sender: UIButton) {
        cadrePersos.hidden = true
        arriveVite(cadreHistoire1)
        boutonGlisse(flecheHistoire)
        let sauvemoi = NSUserDefaults.standardUserDefaults()
        sauvemoi.setInteger(6, forKey: "persochoisi")
        persoChoisi = 6
        installerPerso() }
    @IBAction func perso08(sender: UIButton) {
        cadrePersos.hidden = true
        arriveVite(cadreHistoire1)
        boutonGlisse(flecheHistoire)
        let sauvemoi = NSUserDefaults.standardUserDefaults()
        sauvemoi.setInteger(7, forKey: "persochoisi")
        persoChoisi = 7
        installerPerso() }
    @IBAction func perso09(sender: UIButton) {
        cadrePersos.hidden = true
        arriveVite(cadreHistoire1)
        boutonGlisse(flecheHistoire)
        let sauvemoi = NSUserDefaults.standardUserDefaults()
        sauvemoi.setInteger(8, forKey: "persochoisi")
        persoChoisi = 8
        installerPerso() }
    
    func installerPerso() {
        let imgperso01 = UIImage(named: "perso16chat.png") as UIImage?
        let imgperso02 = UIImage(named: "perso17dog.png") as UIImage?
        let imgperso03 = UIImage(named: "perso14afro.png") as UIImage?
        let imgperso04 = UIImage(named: "perso11girl.png") as UIImage?
        let imgperso05 = UIImage(named: "perso12gi.png") as UIImage?
        let imgperso06 = UIImage(named: "perso09harry.png") as UIImage?
        let imgperso07 = UIImage(named: "perso15woody.png") as UIImage?
        let imgperso08 = UIImage(named: "perso10souris.png") as UIImage?
        let imgperso09 = UIImage(named: "perso13fantome.png") as UIImage?
        switch persoChoisi {
        case 0:
            boutonMenuQuitter.setBackgroundImage(imgperso01, forState: .Normal)
            profilPhoto.image = imgperso01
        case 1:
            boutonMenuQuitter.setBackgroundImage(imgperso02, forState: .Normal)
            profilPhoto.image = imgperso02
        case 2:
            boutonMenuQuitter.setBackgroundImage(imgperso03, forState: .Normal)
            profilPhoto.image = imgperso03
        case 3:
            boutonMenuQuitter.setBackgroundImage(imgperso04, forState: .Normal)
            profilPhoto.image = imgperso04
        case 4:
            boutonMenuQuitter.setBackgroundImage(imgperso05, forState: .Normal)
            profilPhoto.image = imgperso05
        case 5:
            boutonMenuQuitter.setBackgroundImage(imgperso06, forState: .Normal)
            profilPhoto.image = imgperso06
        case 6:
            boutonMenuQuitter.setBackgroundImage(imgperso07, forState: .Normal)
            profilPhoto.image = imgperso07
        case 7:
            boutonMenuQuitter.setBackgroundImage(imgperso08, forState: .Normal)
            profilPhoto.image = imgperso08
        case 8:
            boutonMenuQuitter.setBackgroundImage(imgperso09, forState: .Normal)
            profilPhoto.image = imgperso09
        default:
            boutonMenuQuitter.setBackgroundImage(imgperso01, forState: .Normal)
            profilPhoto.image = imgperso01
        }
    }
    
    @IBOutlet weak var cadreLangues: UIView!
    
    @IBOutlet weak var cadreLanguesLabel: UILabel!
    
    @IBAction func langueEnglish(sender: UIButton) {
        if dansLeJeu == 0 {
            cadreLangues.hidden = true
            arriveVite(cadrePersos)
        } else {
            cadreLangues.hidden = true
            cadreAbout.hidden = false
        }
    }
    @IBAction func langueChinese(sender: UIButton) {
    }
    @IBAction func langueJapanese(sender: UIButton) {
    }
    @IBAction func langueGerman(sender: UIButton) {
    }
    @IBAction func langueSpanish(sender: UIButton) {
    }
    @IBAction func langueRussian(sender: UIButton) {
    }
    @IBAction func langueFrench(sender: UIButton) {
    }
    
    func ouvreProfil(sender:UIButton!){
        
        let savedonc = NSUserDefaults.standardUserDefaults()
        maisonChoisie = savedonc.integerForKey("maisonBanque")
        voitureChoisie = savedonc.integerForKey("voitureBanque")
        piscineChoisie = savedonc.integerForKey("piscineBanque")
        lunettesChoisies = savedonc.integerForKey("lunettesBanque")
        medaillesObtenues = savedonc.integerForKey("medaillesBanque")
        
        let imgPauvre = UIImage(named: "jaugevide.png") as UIImage?
        let imgTaudis = UIImage(named: "profilhouse1.png") as UIImage?
        let imgMaison = UIImage(named: "profilhouse2.png") as UIImage?
        let imgPalais = UIImage(named: "profilhouse3.png") as UIImage?
        let imgVoiture = UIImage(named: "profilcar1.png") as UIImage?
        let imgBerline = UIImage(named: "profilcar2.png") as UIImage?
        let imgSoucoupe = UIImage(named: "profilcar3.png") as UIImage?
        let imgPiscine = UIImage(named: "profilpiscine.png") as UIImage?
        let imgSur1 = UIImage(named: "profilsurprise1.png") as UIImage?
        let imgSur2 = UIImage(named: "profilsurprise2.png") as UIImage?
        let imgSur3 = UIImage(named: "profilsurprise3.png") as UIImage?
        let imgSur4 = UIImage(named: "profilsurprise4.png") as UIImage?
        
        
        switch maisonChoisie {
        case 0:
            profilMaison.image = imgTaudis
        case 1:
            profilMaison.image = imgMaison
        case 2:
            profilMaison.image = imgPalais
        default:
            profilMaison.image = imgTaudis
        }
        switch voitureChoisie {
        case 0:
            profilVoiture.image = imgPauvre
        case 1:
            profilVoiture.image = imgVoiture
        case 2:
            profilVoiture.image = imgBerline
        case 3:
            profilVoiture.image = imgSoucoupe
        default:
            profilMaison.image = imgPauvre
        }
        switch lunettesChoisies {
        case 0:
            profilSurprise.image = imgPauvre
        case 1:
            profilSurprise.image = imgSur1
        case 2:
            profilSurprise.image = imgSur2
        case 3:
            profilSurprise.image = imgSur3
        case 4:
            profilSurprise.image = imgSur4
        default:
            profilSurprise.image = imgPauvre
        }
        switch piscineChoisie {
        case 0:
            projetPiscine.image = imgPauvre
        case 1:
            projetPiscine.image = imgPiscine
        default:
            projetPiscine.image = imgPauvre
        }
        
        profilMedal1.tag = 2001
        profilMedal2.tag = 2002
        profilMedal3.tag = 2003
        profilMedal4.tag = 2004
        profilMedal5.tag = 2005
        profilMedal6.tag = 2006
        profilMedal7.tag = 2007
        profilMedal8.tag = 2008
        profilMedal9.tag = 2009
        profilMedal10.tag = 2010
        profilMedal11.tag = 2011
        profilMedal12.tag = 2012
        
        let niveauMedaille:Int = Int(2001+((niveauAtteint-97)/16))
        for var numeros = 2001; numeros < niveauMedaille; ++numeros {
            let medDeb = self.view.viewWithTag(numeros) as? UIButton
            medDeb?.alpha = 1
        }
        let leRang:Int = Int((2555/(scoreMoyen+1))+1)
        profilRankLabel.text = NSLocalizedString("WORLD_RANK",comment:"World Rank : #")+String(leRang)
        profilScoreLabel.text = NSLocalizedString("MY_SCORE",comment:"My score : ")+String(scoreMoyen)
        
        arriveViteBas(cadreProfil)
        cadreNoir.hidden = false
        cadreShop.hidden = true
        cadreAbout.hidden = true
    }
    
    @IBOutlet weak var boutonMenuAbout: UIButton!
    
    @IBOutlet weak var boutonSon: UIButton!
    
    func changerSon(sender: UIButton!) {
        let imgSonOn = UIImage(named: "menusonon.png") as UIImage?
        let imgSonOff = UIImage(named: "menusonoff.png") as UIImage?
        let sauveglop = NSUserDefaults.standardUserDefaults()
        if isPlaying {
            audioPlayer.stop()
            isPlaying = false
            boutonSon.setBackgroundImage(imgSonOff, forState: .Normal)
            sauveglop.setInteger(1, forKey: "melomane")
        } else {
            audioPlayer.play()
            isPlaying = true
            boutonSon.setBackgroundImage(imgSonOn, forState: .Normal)
            sauveglop.setInteger(0, forKey: "melomane")
        }
    }

    @IBOutlet weak var boutonMenuShop: UIButton!
    
    func ouvreAbout(sender:UIButton!){
        arriveViteBas(cadreAbout)
        cadreNoir.hidden = false
        cadreShop.hidden = true
        cadreProfil.hidden = true
    }
    
    @IBOutlet weak var cadreProfil: UIView!
    
    @IBOutlet weak var profilMaison: UIImageView!
    
    @IBOutlet weak var profilPhoto: UIImageView!
    
    @IBOutlet weak var projetPiscine: UIImageView!
    
    @IBOutlet weak var profilVoiture: UIImageView!
    
    @IBOutlet weak var profilSurprise: UIImageView!
    
    @IBAction func boutonQuitProfil(sender: UIButton) {
        cadreNoir.hidden = true
        cadreProfil.hidden = true
    }
    
    @IBOutlet weak var profilRankLabel: UILabel!
    
    @IBOutlet weak var profilScoreLabel: UILabel!
    
    @IBOutlet weak var profilMedal1: UIButton!
    @IBOutlet weak var profilMedal2: UIButton!
    @IBOutlet weak var profilMedal3: UIButton!
    @IBOutlet weak var profilMedal4: UIButton!
    @IBOutlet weak var profilMedal5: UIButton!
    @IBOutlet weak var profilMedal6: UIButton!
    @IBOutlet weak var profilMedal7: UIButton!
    @IBOutlet weak var profilMedal8: UIButton!
    @IBOutlet weak var profilMedal9: UIButton!
    @IBOutlet weak var profilMedal10: UIButton!
    @IBOutlet weak var profilMedal11: UIButton!
    @IBOutlet weak var profilMedal12: UIButton!
    
    
    func ouvreShop(sender:UIButton!){
        arriveViteBas(cadreShop)
        cadreNoir.hidden = false
        cadreAbout.hidden = true
        cadreProfil.hidden = true
        boutonGrossit(boutonQuitShop)
    }
    
    @IBOutlet weak var cadreAbout: UIView!
    
    @IBAction func boutonQuitAbout(sender: UIButton) {
        cadreNoir.hidden = true
        cadreAbout.hidden = true
    }
    
    @IBAction func boutonFBPage(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.facebook.com/massicotgame")!)
    }
    
    @IBOutlet weak var boutonLangue: UIButton!
    
    func choisirLangue(sender:UIButton!){
        dansLeJeu = 1
    }
    
    @IBOutlet weak var cadreShop: UIView!
    
    @IBOutlet weak var scrollShop: UIScrollView!
    
    @IBOutlet weak var shopValide: UIImageView!
    
    @IBOutlet weak var boutonQuitShop: UIButton!
    
    func quitteShop(sender:UIButton!){
        cadreNoir.hidden = true
        cadreShop.hidden = true
    }
    
    @IBOutlet weak var achat1: UIButton!
    
    func achatN1(sender:UIButton!){
        let quelleSurprise = Int(1+(arc4random_uniform(3)))
        let sauvewhat = NSUserDefaults.standardUserDefaults()
        let shopOui = UIImage(named: "shopyes.png") as UIImage?
        let shopNon = UIImage(named: "shopno.png") as UIImage?
        if sender.tag == 1001 && swiftris.score > 3000 && swiftris.cadeau1 == 9 && swiftris.cadeau2 == 9 && swiftris.cadeau3 == 9 {
            shopValide.image = shopNon
            disparaitVite(shopValide)
        } else if sender.tag == 1001 && swiftris.score > 3000 {
            swiftris.score -= 3000
            swiftris.cadeau1 = 9
            swiftris.cadeau2 = 9
            swiftris.cadeau3 = 9
            shopValide.image = shopOui
            disparaitVite(shopValide)
        } else if sender.tag == 1001 {
            arriveVite(cadreBourse)
        } else if sender.tag == 1002 && swiftris.score > 5555 && swiftris.vies == 5 {
            shopValide.image = shopNon
            disparaitVite(shopValide)
        } else if sender.tag == 1002 && swiftris.score > 5555 {
            swiftris.score -= 5555
            swiftris.vies = 5
            shopValide.image = shopOui
            disparaitVite(shopValide)
        } else if sender.tag == 1002 {
            arriveVite(cadreBourse)
        } else if sender.tag == 1003 && swiftris.score > 300 {
            swiftris.score -= 300
            lunettesChoisies = quelleSurprise
            shopValide.image = shopOui
            disparaitVite(shopValide)
        } else if sender.tag == 1003 {
            arriveVite(cadreBourse)
        } else if sender.tag == 1004 && swiftris.score > 1500 && maisonChoisie == 1 {
            shopValide.image = shopNon
            disparaitVite(shopValide)
        } else if sender.tag == 1004 && swiftris.score > 1500 {
            swiftris.score -= 1500
            maisonChoisie = 1
            shopValide.image = shopOui
            disparaitVite(shopValide)
        } else if sender.tag == 1004 {
            arriveVite(cadreBourse)
        } else if sender.tag == 1005 && swiftris.score > 3100 && maisonChoisie == 2 {
            shopValide.image = shopNon
            disparaitVite(shopValide)
        } else if sender.tag == 1005 && swiftris.score > 3100 {
            swiftris.score -= 3100
            maisonChoisie = 2
            shopValide.image = shopOui
            disparaitVite(shopValide)
        } else if sender.tag == 1005 {
            arriveVite(cadreBourse)
        } else if sender.tag == 1006 && swiftris.score > 1199 && voitureChoisie == 1 {
            shopValide.image = shopNon
            disparaitVite(shopValide)
        } else if sender.tag == 1006 && swiftris.score > 1199 {
            swiftris.score -= 1199
            voitureChoisie = 1
            shopValide.image = shopOui
            disparaitVite(shopValide)
        } else if sender.tag == 1006 {
            arriveVite(cadreBourse)
        } else if sender.tag == 1007 && swiftris.score > 1990 && voitureChoisie == 2 {
            shopValide.image = shopNon
            disparaitVite(shopValide)
        } else if sender.tag == 1007 && swiftris.score > 1990 {
            swiftris.score -= 1990
            voitureChoisie = 2
            shopValide.image = shopOui
            disparaitVite(shopValide)
        } else if sender.tag == 1007 {
            arriveVite(cadreBourse)
        } else if sender.tag == 1008 && swiftris.score > 5000 && voitureChoisie == 3 {
            shopValide.image = shopNon
            disparaitVite(shopValide)
        } else if sender.tag == 1008 && swiftris.score > 5000 {
            swiftris.score -= 5000
            voitureChoisie = 3
            shopValide.image = shopOui
            disparaitVite(shopValide)
        } else if sender.tag == 1008 {
            arriveVite(cadreBourse)
        } else if sender.tag == 1009 && swiftris.score > 1200 && piscineChoisie == 1 {
            shopValide.image = shopNon
            disparaitVite(shopValide)
        } else if sender.tag == 1009 && swiftris.score > 1200 {
            swiftris.score -= 1200
            piscineChoisie = 1
            shopValide.image = shopOui
            disparaitVite(shopValide)
        } else if sender.tag == 1009 {
            arriveVite(cadreBourse)
        } else {
            cadreShop.hidden = false
        }
        
        scoreLabel.text = "\(swiftris.score)"
        viesLabel.text = "\(swiftris.vies)"
        sauvewhat.setInteger(swiftris.score, forKey: "argentBanque")
        sauvewhat.setInteger(swiftris.cadeau1, forKey: "jokerBanque")
        sauvewhat.setInteger(swiftris.cadeau2, forKey: "magiceyeBanque")
        sauvewhat.setInteger(swiftris.cadeau3, forKey: "refillBanque")
        sauvewhat.setInteger(swiftris.vies, forKey: "viesBanque")
        sauvewhat.setInteger(maisonChoisie, forKey: "maisonBanque")
        sauvewhat.setInteger(voitureChoisie, forKey: "voitureBanque")
        sauvewhat.setInteger(piscineChoisie, forKey: "piscineBanque")
        sauvewhat.setInteger(lunettesChoisies, forKey: "lunettesBanque")
    }
    @IBOutlet weak var achat2: UIButton!
    @IBOutlet weak var achat3: UIButton!
    @IBOutlet weak var achat4: UIButton!
    @IBOutlet weak var achat5: UIButton!
    @IBOutlet weak var achat6: UIButton!
    @IBOutlet weak var achat7: UIButton!
    @IBOutlet weak var achat8: UIButton!
    @IBOutlet weak var achat9: UIButton!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var viesLabel: UILabel!
    
    @IBOutlet weak var vies2Label: UILabel!
    
    @IBOutlet weak var levelLabel: UILabel!
    
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var gainLabel: UILabel!
    
    @IBOutlet weak var compteurLabel: UILabel!
    
    @IBOutlet weak var gainkado1Label: UILabel!
    
    @IBOutlet weak var gainkado1Image: UIImageView!
    
    @IBOutlet weak var cadreNoir: UIView!
    
    @IBOutlet weak var cadreNoirJeu: UIView!
    
    @IBOutlet weak var cadreDebut: UIView!
    
    @IBOutlet weak var boutonduDebut: UIButton!
    
    func boutonDebut(sender:UIButton!){
        disparaitDelai(cadreCharge)
        disparaitDelai2(cadreDebut)
    }
    
    func vraiDebut(){

        leMonde.contentSize = CGSize(width: view.frame.width, height: 3457)
        scrollShop.contentSize = CGSize(width: 240, height: 450)
        degageMenu1(cadreDebut)
        cadrePersos.hidden = false
        leMonde.hidden = false
        barreBasMenu.hidden = false
        cadreNoir.hidden = false
        let savegarde = NSUserDefaults.standardUserDefaults()
        swiftris.score = savegarde.integerForKey("argentBanque")
        swiftris.vies = savegarde.integerForKey("viesBanque")
        niveauAtteint = 1
        if let _:Int = savegarde.integerForKey("episodeAtteint") {
            niveauAtteint = savegarde.integerForKey("episodeAtteint")
        }
        swiftris.cadeau1 = savegarde.integerForKey("jokerBanque")
        swiftris.cadeau2 = savegarde.integerForKey("magiceyeBanque")
        swiftris.cadeau3 = savegarde.integerForKey("refillBanque")
        cadeau3Label.text = String(swiftris.cadeau2)
        cadeau2Label.text = String(swiftris.cadeau3)
        cadeau1Label.text = String(swiftris.cadeau1)
        scoreLabel.text = "\(swiftris.score)"
        melomaneOuPas = savegarde.integerForKey("melomane")
        persoChoisi = savegarde.integerForKey("persochoisi")
        scoreMoyen = savegarde.integerForKey("moyenBanque")
        medaillesObtenues = savegarde.integerForKey("medaillesBanque")
        
        dateDefaite = 19830.008
        
        if let _:Double = savegarde.doubleForKey("dateBanque") {
            dateDefaite = savegarde.doubleForKey("dateBanque")
        }
        
        maisonChoisie = savegarde.integerForKey("maisonBanque")
        voitureChoisie = savegarde.integerForKey("voitureBanque")
        piscineChoisie = savegarde.integerForKey("piscineBanque")
        var influMaison:Double = 0
        var influVoiture:Double = 0
        var influPiscine:Double = 0
        
        switch maisonChoisie {
        case 0:
            influMaison = 0
        case 1:
            influMaison = 5
        case 2:
            influMaison = 10
        default:
            influMaison = 0
        }
        switch voitureChoisie {
        case 0:
            influVoiture = 0
        case 1:
            influVoiture = 5
        case 2:
            influVoiture = 8
        case 3:
            influVoiture = 15
        default:
            influVoiture = 0
        }
        switch piscineChoisie {
        case 0:
            influPiscine = 0
        case 1:
            influPiscine = 5
        default:
            influPiscine = 0
        }
        
        influTotale = influMaison+influPiscine+influVoiture
        
        let tempskiPasse = CFAbsoluteTimeGetCurrent() - dateDefaite!
        let tempsinMinutes:Double = 50-influTotale-(tempskiPasse/60)
        let tempsKonverti:Int = Int(tempsinMinutes)
        
        if swiftris.vies == 0 && tempsinMinutes <= 0 {
            swiftris.vies = 5
            viesLabel.text = "\(swiftris.vies)"
            savegarde.setInteger(swiftris.vies, forKey: "viesBanque")
        }
        
        installerPerso()
    
        if let estcefait = savegarde.stringForKey("dejafait") {
           if estcefait == "voila" {
               if isPlaying == true {
                   scene.playSound("pourlewin.mp3")
               }
               cadrePersos.hidden = true
               barreHaut.hidden = false
               cadreNoir.hidden = true
           } else {
               savegarde.setInteger(5, forKey: "viesBanque")
           }
        }
        swiftris.vies = savegarde.integerForKey("viesBanque")
        viesLabel.text = "\(swiftris.vies)"
        
        let imgSonOn = UIImage(named: "menusonon.png") as UIImage?
        let imgSonOff = UIImage(named: "menusonoff.png") as UIImage?
        if melomaneOuPas == 0 {
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            isPlaying = true
            boutonSon.setBackgroundImage(imgSonOn, forState: .Normal)
        } else {
            isPlaying = false
            boutonSon.setBackgroundImage(imgSonOff, forState: .Normal)
        }
        
        if niveauAtteint == 0 {
            niveauAtteint = 1
        }

        var niveauDansLeMonde = niveauAtteint%96
        if niveauAtteint == 96 || niveauAtteint == 192 || niveauAtteint == 288 {
            niveauDansLeMonde = 96
        }
        let quelLointain:Int = Int((2890/96)*niveauDansLeMonde)

        if niveauAtteint > 96 && niveauAtteint < 193 {
            allerMonde2()
        } else if niveauAtteint > 192 {
            allerMonde3()
        } else {
            mondeActuel = 1
            
            for var numeros = 1; numeros < (niveauAtteint+1); ++numeros {
                let boutonsDebloques = self.view.viewWithTag(numeros) as? UIButton
                let imagesDebloquees = UIImage(named: "mondecercle.png") as UIImage?
                let imagesNow = UIImage(named: "mondecerclenow.png") as UIImage?
                boutonsDebloques?.addTarget(self, action: "boutonEpisode:", forControlEvents:.TouchUpInside)
                boutonsDebloques?.setBackgroundImage(imagesDebloquees, forState: .Normal)
                if numeros == niveauAtteint {
                    boutonsDebloques?.setBackgroundImage(imagesNow, forState: .Normal)
                }
            }
            
            let caBrille = self.view.viewWithTag(niveauAtteint) as? UIButton
            boutonGrossit(caBrille!)
        }
        leMonde.contentOffset = CGPoint(x: 0, y: quelLointain)
    }
    
    @IBOutlet weak var cadreConfirm: UIView!
    
    @IBOutlet weak var fondecran: UIImageView!
    
    @IBOutlet weak var cadreJeu: UIView!
    
    @IBOutlet weak var cadreJoujou: UIView!

    @IBOutlet weak var fondRouge: UIView!
    
    @IBOutlet weak var fondVert: UIView!

    
    @IBOutlet weak var taler1: UIImageView!
    @IBOutlet weak var taler2: UIImageView!
    @IBOutlet weak var taler3: UIImageView!
    @IBOutlet weak var taler4: UIImageView!
    @IBOutlet weak var taler5: UIImageView!
    @IBOutlet weak var taler6: UIImageView!
    @IBOutlet weak var taler7: UIImageView!
    @IBOutlet weak var taler8: UIImageView!
    @IBOutlet weak var taler9: UIImageView!
    @IBOutlet weak var taler10: UIImageView!
    
    @IBOutlet weak var rond1: UIButton!
    @IBOutlet weak var rond2: UIButton!
    @IBOutlet weak var rond3: UIButton!
    @IBOutlet weak var rond4: UIButton!
    @IBOutlet weak var rond5: UIButton!
    @IBOutlet weak var rond6: UIButton!
    @IBOutlet weak var rond7: UIButton!
    @IBOutlet weak var rond8: UIButton!
    @IBOutlet weak var rond9: UIButton!
    @IBOutlet weak var rond10: UIButton!
    @IBOutlet weak var rond11: UIButton!
    @IBOutlet weak var rond12: UIButton!
    @IBOutlet weak var rond13: UIButton!
    @IBOutlet weak var rond14: UIButton!
    @IBOutlet weak var rond15: UIButton!
    @IBOutlet weak var rond16: UIButton!
    @IBOutlet weak var rond17: UIButton!
    @IBOutlet weak var rond18: UIButton!
    @IBOutlet weak var rond19: UIButton!
    @IBOutlet weak var rond20: UIButton!
    @IBOutlet weak var rond21: UIButton!
    @IBOutlet weak var rond22: UIButton!
    @IBOutlet weak var rond23: UIButton!
    @IBOutlet weak var rond24: UIButton!
    @IBOutlet weak var rond25: UIButton!
    @IBOutlet weak var rond26: UIButton!
    @IBOutlet weak var rond27: UIButton!
    @IBOutlet weak var rond28: UIButton!
    @IBOutlet weak var rond29: UIButton!
    @IBOutlet weak var rond30: UIButton!
    @IBOutlet weak var rond31: UIButton!
    @IBOutlet weak var rond32: UIButton!
    @IBOutlet weak var rond33: UIButton!
    @IBOutlet weak var rond34: UIButton!
    @IBOutlet weak var rond35: UIButton!
    @IBOutlet weak var rond36: UIButton!
    @IBOutlet weak var rond37: UIButton!
    @IBOutlet weak var rond38: UIButton!
    @IBOutlet weak var rond39: UIButton!
    @IBOutlet weak var rond40: UIButton!
    @IBOutlet weak var rond41: UIButton!
    @IBOutlet weak var rond42: UIButton!
    @IBOutlet weak var rond43: UIButton!
    @IBOutlet weak var rond44: UIButton!
    @IBOutlet weak var rond45: UIButton!
    @IBOutlet weak var rond46: UIButton!
    @IBOutlet weak var rond47: UIButton!
    @IBOutlet weak var rond48: UIButton!
    @IBOutlet weak var rond49: UIButton!
    @IBOutlet weak var rond50: UIButton!
    @IBOutlet weak var rond51: UIButton!
    @IBOutlet weak var rond52: UIButton!
    @IBOutlet weak var rond53: UIButton!
    @IBOutlet weak var rond54: UIButton!
    @IBOutlet weak var rond55: UIButton!
    @IBOutlet weak var rond56: UIButton!
    @IBOutlet weak var rond57: UIButton!
    @IBOutlet weak var rond58: UIButton!
    @IBOutlet weak var rond59: UIButton!
    @IBOutlet weak var rond60: UIButton!
    @IBOutlet weak var rond61: UIButton!
    @IBOutlet weak var rond62: UIButton!
    @IBOutlet weak var rond63: UIButton!
    @IBOutlet weak var mondeBoot: UIImageView!
    @IBOutlet weak var mondeZep: UIImageView!
    @IBOutlet weak var rond64: UIButton!
    @IBOutlet weak var rond65: UIButton!
    @IBOutlet weak var rond66: UIButton!
    @IBOutlet weak var rond67: UIButton!
    @IBOutlet weak var rond68: UIButton!
    @IBOutlet weak var rond69: UIButton!
    @IBOutlet weak var rond70: UIButton!
    @IBOutlet weak var rond71: UIButton!
    @IBOutlet weak var rond72: UIButton!
    @IBOutlet weak var rond73: UIButton!
    @IBOutlet weak var rond74: UIButton!
    @IBOutlet weak var rond75: UIButton!
    @IBOutlet weak var rond76: UIButton!
    @IBOutlet weak var rond77: UIButton!
    @IBOutlet weak var rond78: UIButton!
    @IBOutlet weak var rond79: UIButton!
    @IBOutlet weak var rond80: UIButton!
    @IBOutlet weak var rond81: UIButton!
    @IBOutlet weak var rond82: UIButton!
    @IBOutlet weak var rond83: UIButton!
    @IBOutlet weak var rond84: UIButton!
    @IBOutlet weak var rond85: UIButton!
    @IBOutlet weak var rond86: UIButton!
    @IBOutlet weak var rond87: UIButton!
    @IBOutlet weak var rond88: UIButton!
    @IBOutlet weak var rond89: UIButton!
    @IBOutlet weak var rond90: UIButton!
    @IBOutlet weak var rond91: UIButton!
    @IBOutlet weak var rond92: UIButton!
    @IBOutlet weak var rond93: UIButton!
    @IBOutlet weak var rond94: UIButton!
    @IBOutlet weak var rond95: UIButton!
    @IBOutlet weak var rond96: UIButton!
    @IBOutlet weak var porteMondeBas: UIButton!
    @IBOutlet weak var porteMondeHaut: UIButton!
    
    @IBOutlet weak var fondMonde: UIImageView!
    
    func allerMonde2() {

        let imgFondMonde2 = UIImage(named: "mondetour1.png") as UIImage?
        let imgFlecheHaut = UIImage(named: "mondeportehaut.png") as UIImage?
        
        fondMonde.image = imgFondMonde2
        mondeActuel = 2
        porteMondeHaut.setBackgroundImage(imgFlecheHaut, forState: .Normal)
        boutonGrossit(porteMondeHaut)
        boutonGrossit(porteMondeBas)
        for var noix = 1; noix < 97; ++noix {
            let boutonsNeufs = self.view.viewWithTag(noix) as? UIButton
            boutonsNeufs?.tag += 96
        }
        for var noixe = 97; noixe < (niveauAtteint+1); ++noixe {
            let boutonsNeufs = self.view.viewWithTag(noixe) as? UIButton
            let imagesNeuves = UIImage(named: "mondecercle.png") as UIImage?
            let imagesNeuvesNow = UIImage(named: "mondecerclenow.png") as UIImage?
            boutonsNeufs?.addTarget(self, action: "boutonEpisode:", forControlEvents:.TouchUpInside)
            boutonsNeufs?.setBackgroundImage(imagesNeuves, forState: .Normal)
            if noixe == niveauAtteint {
                boutonsNeufs?.setBackgroundImage(imagesNeuvesNow, forState: .Normal)
            }
        }
        for var noixed = (niveauAtteint+1); noixed < 193; ++noixed {
            let boutonsNeufs = self.view.viewWithTag(noixed) as? UIButton
            let imagesNeuves = UIImage(named: "mondecadenas.png") as UIImage?
            boutonsNeufs?.removeTarget(self, action: "boutonEpisode:", forControlEvents:.TouchUpInside)
            boutonsNeufs?.setBackgroundImage(imagesNeuves, forState: .Normal)
        }
        
    }
    
    func allerMonde3() {
        let imgFondMonde3 = UIImage(named: "mondetour2.png") as UIImage?
        let imgFlecheHaut = UIImage(named: "mondeportehaut.png") as UIImage?
        let imgFlecheVide = UIImage(named: "jaugevide.png") as UIImage?
        let imgNuage = UIImage(named: "mondenuage2.png") as UIImage?
        
        fondMonde.image = imgFondMonde3
        porteMondeHaut.setBackgroundImage(imgFlecheHaut, forState: .Normal)
        porteMondeBas.setBackgroundImage(imgFlecheVide, forState: .Normal)
        boutonGrossit(porteMondeHaut)
        boutonGrossit(porteMondeBas)
        mondeBoot.image = imgNuage
        boutonGlisse(mondeBoot)
        if mondeActuel == 1 {
            for var noix = 1; noix < 97; ++noix {
                let boutonsNeufs = self.view.viewWithTag(noix) as? UIButton
                boutonsNeufs?.tag += 192
            }
        }
        if mondeActuel == 2 {
            for var noix = 97; noix < 193; ++noix {
                let boutonsNeufs = self.view.viewWithTag(noix) as? UIButton
                boutonsNeufs?.tag += 96
            }
        }
        for var noixe = 193; noixe < (niveauAtteint+1); ++noixe {
            let boutonsNeufs = self.view.viewWithTag(noixe) as? UIButton
            let imagesNeuves = UIImage(named: "mondecercle.png") as UIImage?
            let imagesNeuvesNow = UIImage(named: "mondecerclenow.png") as UIImage?
            boutonsNeufs?.addTarget(self, action: "boutonEpisode:", forControlEvents:.TouchUpInside)
            boutonsNeufs?.setBackgroundImage(imagesNeuves, forState: .Normal)
            if noixe == niveauAtteint {
                boutonsNeufs?.setBackgroundImage(imagesNeuvesNow, forState: .Normal)
            }
        }
        for var noixed = (niveauAtteint+1); noixed < 289; ++noixed {
            let boutonsNeufs = self.view.viewWithTag(noixed) as? UIButton
            let imagesNeuves = UIImage(named: "mondecadenas.png") as UIImage?
            boutonsNeufs?.removeTarget(self, action: "boutonEpisode:", forControlEvents:.TouchUpInside)
            boutonsNeufs?.setBackgroundImage(imagesNeuves, forState: .Normal)
        }
        mondeActuel = 3
    
    }
    
    func passerPorteBas(sender:UIButton!) {
        transitionPorteLoad(cadreCharge)
        transitionPorteBasse(mondeBoot)
    }
    
    func passerPB() {
        
        let imgFondMonde2 = UIImage(named: "mondetour1.png") as UIImage?
        let imgFondMonde3 = UIImage(named: "mondetour2.png") as UIImage?
        let imgFlecheHaut = UIImage(named: "mondeportehaut.png") as UIImage?
        let imgFlecheVide = UIImage(named: "jaugevide.png") as UIImage?
        let imgNuage = UIImage(named: "mondenuage2.png") as UIImage?
        
        if mondeActuel == 1 {
            fondMonde.image = imgFondMonde2
            mondeActuel = 2
            porteMondeHaut.setBackgroundImage(imgFlecheHaut, forState: .Normal)
            leMonde.contentOffset = CGPoint(x: 0, y: 0)
            boutonGrossit(porteMondeHaut)
            boutonGrossit(porteMondeBas)
            for var noix = 1; noix < 97; ++noix {
                let boutonsNeufs = self.view.viewWithTag(noix) as? UIButton
                boutonsNeufs?.tag += 96
            }
            for var noixe = 97; noixe < (niveauAtteint+1); ++noixe {
                let boutonsNeufs = self.view.viewWithTag(noixe) as? UIButton
                let imagesNeuves = UIImage(named: "mondecercle.png") as UIImage?
                let imagesNeuvesNow = UIImage(named: "mondecerclenow.png") as UIImage?
                boutonsNeufs?.addTarget(self, action: "boutonEpisode:", forControlEvents:.TouchUpInside)
                boutonsNeufs?.setBackgroundImage(imagesNeuves, forState: .Normal)
                if noixe == niveauAtteint {
                    boutonsNeufs?.setBackgroundImage(imagesNeuvesNow, forState: .Normal)
                }
            }
            for var noixed = (niveauAtteint+1); noixed < 193; ++noixed {
                let boutonsNeufs = self.view.viewWithTag(noixed) as? UIButton
                let imagesNeuves = UIImage(named: "mondecadenas.png") as UIImage?
                boutonsNeufs?.removeTarget(self, action: "boutonEpisode:", forControlEvents:.TouchUpInside)
                boutonsNeufs?.setBackgroundImage(imagesNeuves, forState: .Normal)
            }
        } else if mondeActuel == 2 {
            fondMonde.image = imgFondMonde3
            mondeActuel = 3
            porteMondeBas.setBackgroundImage(imgFlecheVide, forState: .Normal)
            leMonde.contentOffset = CGPoint(x: 0, y: 0)
            boutonGrossit(porteMondeHaut)
            boutonGrossit(porteMondeBas)
            mondeBoot.image = imgNuage
            boutonGlisse(mondeBoot)
            for var noix = 97; noix < 193; ++noix {
                let boutonsNeufs = self.view.viewWithTag(noix) as? UIButton
                boutonsNeufs?.tag += 96
            }
            for var noixe = 193; noixe < (niveauAtteint+1); ++noixe {
                let boutonsNeufs = self.view.viewWithTag(noixe) as? UIButton
                let imagesNeuves = UIImage(named: "mondecercle.png") as UIImage?
                let imagesNeuvesNow = UIImage(named: "mondecerclenow.png") as UIImage?
                boutonsNeufs?.addTarget(self, action: "boutonEpisode:", forControlEvents:.TouchUpInside)
                boutonsNeufs?.setBackgroundImage(imagesNeuves, forState: .Normal)
                if noixe == niveauAtteint {
                    boutonsNeufs?.setBackgroundImage(imagesNeuvesNow, forState: .Normal)
                }
            }
            for var noixed = (niveauAtteint+1); noixed < 289; ++noixed {
                let boutonsNeufs = self.view.viewWithTag(noixed) as? UIButton
                let imagesNeuves = UIImage(named: "mondecadenas.png") as UIImage?
                boutonsNeufs?.removeTarget(self, action: "boutonEpisode:", forControlEvents:.TouchUpInside)
                boutonsNeufs?.setBackgroundImage(imagesNeuves, forState: .Normal)
            }
            
        } else {
            cadreNoir.hidden = true
        }
        
    }
    
    func passerPorteHaut(sender:UIButton!) {
        transitionPorteLoad(cadreCharge)
        transitionPorteHaute(mondeBoot)
    }
    
    func passerPH() {
        
        let imgFondMonde1 = UIImage(named: "mondegrand-1.png") as UIImage?
        let imgFondMonde2 = UIImage(named: "mondetour1.png") as UIImage?
        let imgFlecheBas = UIImage(named: "mondeportebas.png") as UIImage?
        let imgFlecheVide = UIImage(named: "jaugevide.png") as UIImage?
        let imgBateau = UIImage(named: "mondebateau.png") as UIImage?
        
        if mondeActuel == 2 {
            fondMonde.image = imgFondMonde1
            mondeActuel = 1
            porteMondeHaut.setBackgroundImage(imgFlecheVide, forState: .Normal)
            boutonGrossit(porteMondeHaut)
            boutonGrossit(porteMondeBas)
            for var noix = 97; noix < 193; ++noix {
                let boutonsNeufs = self.view.viewWithTag(noix) as? UIButton
                boutonsNeufs?.tag -= 96
            }
            for var noixe = 1; noixe < (niveauAtteint+1); ++noixe {
                let boutonsNeufs = self.view.viewWithTag(noixe) as? UIButton
                let imagesNeuves = UIImage(named: "mondecercle.png") as UIImage?
                let imagesNeuvesNow = UIImage(named: "mondecerclenow.png") as UIImage?
                boutonsNeufs?.addTarget(self, action: "boutonEpisode:", forControlEvents:.TouchUpInside)
                boutonsNeufs?.setBackgroundImage(imagesNeuves, forState: .Normal)
                if noixe == niveauAtteint {
                    boutonsNeufs?.setBackgroundImage(imagesNeuvesNow, forState: .Normal)
                }
            }
            for var noixed = (niveauAtteint+1); noixed < 97; ++noixed {
                let boutonsNeufs = self.view.viewWithTag(noixed) as? UIButton
                let imagesNeuves = UIImage(named: "mondecadenas.png") as UIImage?
                boutonsNeufs?.removeTarget(self, action: "boutonEpisode:", forControlEvents:.TouchUpInside)
                boutonsNeufs?.setBackgroundImage(imagesNeuves, forState: .Normal)
            }
        } else if mondeActuel == 3 {
            fondMonde.image = imgFondMonde2
            mondeActuel = 2
            porteMondeBas.setBackgroundImage(imgFlecheBas, forState: .Normal)
            boutonGrossit(porteMondeHaut)
            boutonGrossit(porteMondeBas)
            mondeBoot.image = imgBateau
            boutonGlisse(mondeBoot)
            for var noix = 193; noix < 289; ++noix {
                let boutonsNeufs = self.view.viewWithTag(noix) as? UIButton
                boutonsNeufs?.tag -= 96
            }
            for var noixe = 97; noixe < (niveauAtteint+1); ++noixe {
                let boutonsNeufs = self.view.viewWithTag(noixe) as? UIButton
                let imagesNeuves = UIImage(named: "mondecercle.png") as UIImage?
                let imagesNeuvesNow = UIImage(named: "mondecerclenow.png") as UIImage?
                boutonsNeufs?.addTarget(self, action: "boutonEpisode:", forControlEvents:.TouchUpInside)
                boutonsNeufs?.setBackgroundImage(imagesNeuves, forState: .Normal)
                if noixe == niveauAtteint {
                    boutonsNeufs?.setBackgroundImage(imagesNeuvesNow, forState: .Normal)
                }
            }
            for var noixed = (niveauAtteint+1); noixed < 193; ++noixed {
                let boutonsNeufs = self.view.viewWithTag(noixed) as? UIButton
                let imagesNeuves = UIImage(named: "mondecadenas.png") as UIImage?
                boutonsNeufs?.removeTarget(self, action: "boutonEpisode:", forControlEvents:.TouchUpInside)
                boutonsNeufs?.setBackgroundImage(imagesNeuves, forState: .Normal)
            }
        } else {
            cadreNoir.hidden = true
        }
        
    }
    
    @IBOutlet weak var cadreRank: UIView!
    
    @IBOutlet weak var rankPerso1: UIImageView!
    @IBOutlet weak var rankPerso2: UIImageView!
    @IBOutlet weak var rankPerso3: UIImageView!
    @IBOutlet weak var rankPerso4: UIImageView!
    @IBOutlet weak var rankPerso5: UIImageView!
    @IBOutlet weak var rankLabel1: UILabel!
    @IBOutlet weak var rankLabel2: UILabel!
    @IBOutlet weak var rankLabel3: UILabel!
    @IBOutlet weak var rankLabel4: UILabel!
    @IBOutlet weak var rankLabel5: UILabel!

    @IBAction func quitRank(sender: UIButton) {
        cadreNoir.hidden = true
        cadreRank.hidden = true
    }
    
    @IBOutlet weak var cadreHistoireSansFin: UIView!
    @IBOutlet weak var histoireSansFinLabel: UILabel!
    @IBOutlet weak var histoireSansFinBouton: UIButton!
    
    func quitterHSF(sender:UIButton!) {
        cadreNoir.hidden = true
        cadreHistoireSansFin.hidden = true
    }

    
    func boutonEpisode(sender:UIButton!) {
        cadreNoir.hidden = false
        boutonGrossit(boutonCestParti)
        let niveauClique = sender.tag
        
        dateDefaite = 19830
        let soovegarde = NSUserDefaults.standardUserDefaults()
        if let lastDefaite:Double = soovegarde.doubleForKey("dateBanque") {
            dateDefaite = soovegarde.doubleForKey("dateBanque")
        }
        let tempskiPasse = CFAbsoluteTimeGetCurrent() - dateDefaite!
        let tempsinMinutes:Double = 50-(tempskiPasse/60)
        let tempsKonverti:Int = Int(tempsinMinutes)
        
        if swiftris.vies < 1 && tempsinMinutes > 0 {
            swiftris.waitGame()
            boutonGrossit(speedUpSommeil)
        } else if swiftris.vies < 1 && tempsinMinutes <= 0 {
            swiftris.vies = 5
            soovegarde.setInteger(swiftris.vies, forKey: "viesBanque")
            
            swiftris.level = niveauClique
            arriveVite(cadreHaut)
            if isPlaying == true {
                audioPlayer.stop()
                audioJeu.prepareToPlay()
                audioJeu.play()
            }
            swiftris.introGame()
            nouveauNiveau()
        } else {
            swiftris.level = niveauClique
            arriveVite(cadreHaut)
            if isPlaying == true {
                audioPlayer.stop()
                audioJeu.prepareToPlay()
                audioJeu.play()
            }
            swiftris.introGame()
            nouveauNiveau()
        }
    }

    
    @IBOutlet weak var boutonDeGauche: UIButton!
    
    @IBOutlet weak var boutonDuMilieu: UIButton!
    
    @IBOutlet weak var boutonDeDroite: UIButton!
    
    @IBOutlet weak var cadreHaut: UIView!
    
    @IBOutlet weak var medaillon: UIImageView!
    
    @IBOutlet weak var medaillonModePoints: UIImageView!
    
    @IBOutlet weak var carreRose: UIView!

    @IBOutlet weak var medaillonMode: UIImageView!
    
    @IBOutlet weak var cadreHistoire1: UIView!
    
    @IBAction func viesProvisoire(sender: UIButton) {

    }
    @IBOutlet weak var cadreHistoire2: UIView!
    
    @IBOutlet weak var flecheHistoire: UIButton!
    
    @IBOutlet weak var histoireMain: UIImageView!
    
    @IBAction func boutonHistoire2(sender: UIButton) {
        degageMenu1(cadreHistoire2)
        if isPlaying == true {
            scene.playSound("songagne.mp3")
        }
        cadreNoir.hidden = true
        let dejaFait = NSUserDefaults.standardUserDefaults()
        dejaFait.setObject("voila", forKey: "dejafait")
        barreHaut.hidden = false
        dejaFait.setInteger(5, forKey: "viesBanque")
        dejaFait.setInteger(1, forKey: "episodeAtteint")
        niveauAtteint = dejaFait.integerForKey("episodeAtteint")
        swiftris.vies = dejaFait.integerForKey("viesBanque")
        viesLabel.text = "\(swiftris.vies)"
    
    }
    
    @IBOutlet weak var boutonCadeauTombe: UIButton!
    
    @IBOutlet weak var cadreWin: UIView!
    
    @IBOutlet weak var cadreWinPost: UIView!
    
    @IBOutlet weak var sablierLabel: UILabel!
    
    @IBOutlet weak var cagnotteLabel: UILabel!
    
    @IBOutlet weak var sablierImage: UIImageView!
    
    @IBOutlet weak var cadrePresque: UIView!
    
    @IBOutlet weak var presqueLabel: UILabel!
    
    @IBOutlet weak var boutonContinue: UIButton!
    
    func continuerPayer(sender:UIButton!){
        cadreCharge.hidden = false
        cadreCharge.alpha = 1
        cadreReseau.hidden = false
        for product in listeProduits {
            var prodID = product.productIdentifier
            if(prodID == "com.emg.Massicot.littlehelp") {
                cadreReseau.hidden = true
                achatEnCours = product
                acheterProduit()
                break;
            }
        }
    }
    
    @IBOutlet weak var boutonPasContinue: UIButton!
    
    @IBOutlet weak var cadreLose: UIView!
    
    @IBOutlet weak var cadreCadeau: UIView!
    
    @IBOutlet weak var tempsLabel: UILabel!
    
    @IBOutlet weak var barreBas: UIView!
    
    @IBOutlet weak var barreBasMenu: UIView!
    
    @IBOutlet weak var barreHaut: UIView!

    @IBOutlet weak var barreBoost: UIView!
    
    @IBOutlet weak var barreBoost2: UIView!
    
    @IBOutlet weak var perfectLabel: UILabel!
    
    @IBOutlet weak var banniereMode: UIImageView!
    
    @IBOutlet weak var petitFondBleu1: UIImageView!
    
    @IBOutlet weak var petitFondBleu2: UIImageView!
    
    @IBAction func boutonJoker(sender: UIButton) {
        if swiftris.cadeau1 > 0 {
            swiftris.beginGame()
            if isPlaying == true {
                scene.playSound("sondejoker.mp3")
            }
            perfectLabel.text = "SHUFFLE"
            perfectLabel.textColor = UIColor.redColor()
            boutonGrossit(perfectLabel)
            perfectLabel.hidden = false
            perfectLabel.alpha = 1
            swiftris.cadeau1 -= 1
            cadeau1Label.text = String(swiftris.cadeau1)
            let sauveggg = NSUserDefaults.standardUserDefaults()
            sauveggg.setInteger(swiftris.cadeau1, forKey: "jokerBanque")
        }
    }
    
    @IBAction func boutonMagic(sender: UIButton) {
        if swiftris.cadeau2 > 0 {
            if isPlaying == true {
                scene.playSound("sondejoker.mp3")
            }
            swiftris.cadeau2 -= 1
            cadeau3Label.text = String(swiftris.cadeau2)
            let sauveggg = NSUserDefaults.standardUserDefaults()
            sauveggg.setInteger(swiftris.cadeau2, forKey: "magiceyeBanque")
            if choixFait == "gauche" {
                boutonDuMilieu.alpha = 0.2
                boutonDeDroite.alpha = 0.2
            } else if choixFait == "milieu" {
                boutonDeGauche.alpha = 0.2
                boutonDeDroite.alpha = 0.2
            } else if choixFait == "droite" {
                boutonDuMilieu.alpha = 0.2
                boutonDeGauche.alpha = 0.2
            }
        }
    }
    
    @IBAction func boutonRefill(sender: UIButton) {
        
        if swiftris.cadeau3 > 0 && onceRefill < 1 {
            
            // desactiver pour les MP 2 et 4
            
            if modePoints == 3 && compteur > 10 {
                if isPlaying == true {
                    scene.playSound("sondejoker.mp3")
                }
                swiftris.cadeau3 -= 1
                onceRefill = 1
                cadeau2Label.text = String(swiftris.cadeau3)
                compteur -= 10
                let compteurFoisDeux:Int = Int((120-compteur)/2)
                compteurLabel.text = String(compteurFoisDeux)+"s"
                barreBoost.frame.size.height = CGFloat(150-(compteur*125/100))
                barreBoost.frame.origin.y = 195-CGFloat(150-(compteur*125/100))
                let sauveggg = NSUserDefaults.standardUserDefaults()
                sauveggg.setInteger(swiftris.cadeau3, forKey: "refillBanque")
            } else if modePoints == 4 {
                barreBoost.hidden = false
            } else if compteur > 5 {
                if isPlaying == true {
                    scene.playSound("sondejoker.mp3")
                }
                swiftris.cadeau3 -= 1
                onceRefill = 1
                cadeau2Label.text = String(swiftris.cadeau3)
                compteur -= 5
                compteurLabel.text = String(30-compteur)
                barreBoost.frame.size.height = CGFloat(150-(compteur*5))
                barreBoost.frame.origin.y = 45+CGFloat(compteur*5)
                if compteur < 0 {
                    barreBoost.frame.size.height = 150
                    barreBoost.frame.origin.y = 45
                }
                let sauveggg = NSUserDefaults.standardUserDefaults()
                sauveggg.setInteger(swiftris.cadeau3, forKey: "refillBanque")
            }
        }
    }
    
    @IBOutlet weak var cadeau1Label: UILabel!
    
    @IBOutlet weak var cadeau2Label: UILabel!
    
    @IBOutlet weak var cadeau3Label: UILabel!
    
    @IBOutlet weak var cadreWait: UIView!
    
    @IBOutlet weak var attenteLabel: UILabel!

    @IBOutlet weak var boutonBooster: UIButton!
    
    @IBOutlet weak var boutonBooster2: UIButton!
    
    @IBOutlet weak var boutonCestParti: UIButton!
    
    @IBOutlet weak var boutonCestPartiAmi: UIButton!
    
    func chargerWin(sender:UIButton!){
        if tempsPartie == 0 {
            tempsPartie = 1
        }
        let argentCagnard:Int = Int(2015/tempsPartie)
        gainCumule = argentCagnard
        scoreProvisoire = argentCagnard*23
        if scoreProvisoire > scoreMoyen {
            scoreMoyen += 19
        } else {
            scoreMoyen -= 19
        }
        if isPlaying == true {
            scene.playSound("sondewinset.mp3")
        }
        let sauveich = NSUserDefaults.standardUserDefaults()
        sauveich.setInteger(scoreMoyen, forKey: "moyenBanque")
        boutonCadeauTombe.hidden = true
        cadreWinPost.hidden = false
    }

    @IBAction func boutonWin(sender: UIButton) {
        degageMenu1(cadreWin)
        swiftris.level += 1
        let sauvegarde = NSUserDefaults.standardUserDefaults()

        if swiftris.level == 97 {
            if swiftris.level > niveauAtteint {
                niveauAtteint += 1
                sauvegarde.setInteger(niveauAtteint, forKey: "episodeAtteint")
            }
            cadreNoir.hidden = false
            boutonGlisse(histoireSansFinBouton)
            arriveVite(cadreHistoireSansFin)
            allerMonde2()
        } else if swiftris.level == 193 {
            if swiftris.level > niveauAtteint {
                niveauAtteint += 1
                sauvegarde.setInteger(niveauAtteint, forKey: "episodeAtteint")
            }
            cadreNoir.hidden = false
            boutonGlisse(histoireSansFinBouton)
            histoireSansFinLabel.text = NSLocalizedString("HISTOIRE_A",comment:"Wow! You're getting closer to the Ultimate Massicot!")
            arriveVite(cadreHistoireSansFin)
            allerMonde3()
        } else if swiftris.level == 289 {
            if swiftris.level > niveauAtteint {
                swiftris.level = 288
                niveauAtteint == 288
                sauvegarde.setInteger(niveauAtteint, forKey: "episodeAtteint")
            }
            cadreNoir.hidden = false
            boutonGlisse(histoireSansFinBouton)
            histoireSansFinLabel.text = NSLocalizedString("HISTOIRE_A",comment:"Wow! You're getting closer to the Ultimate Massicot!")
            arriveVite(cadreHistoireSansFin)
        } else {
    
            if swiftris.level > niveauAtteint {
                let niveauFutur = niveauAtteint+1
                let futurBouton = self.view.viewWithTag(niveauFutur) as? UIButton
                let passeBouton = self.view.viewWithTag(niveauAtteint) as? UIButton
                let boutonDebloque = UIImage(named: "mondecerclenow.png") as UIImage?
                let boutonAncien = UIImage(named: "mondecercle.png") as UIImage?
                niveauAtteint += 1
                sauvegarde.setInteger(niveauAtteint, forKey: "episodeAtteint")
                futurBouton?.addTarget(self, action: "boutonEpisode:", forControlEvents:.TouchUpInside)
                futurBouton?.setBackgroundImage(boutonDebloque, forState: .Normal)
                passeBouton?.setBackgroundImage(boutonAncien, forState: .Normal)
                
                if niveauAtteint == 0 {
                    niveauAtteint = 1
                }
                let caBrillos = self.view.viewWithTag(niveauAtteint) as? UIButton
                boutonGrossit(caBrillos!)
            }
            
        }
        
        
        cadreJoujou.hidden = true
        cadreJeu.hidden = true
        
        grosPointillesv.hidden = true
        grosPointillesh.hidden = true
        barreBas.hidden = true
        taler1.hidden = true
        taler2.hidden = true
        taler3.hidden = true
        taler4.hidden = true
        taler5.hidden = true
        taler6.hidden = true
        taler7.hidden = true
        taler8.hidden = true
        taler9.hidden = true
        taler10.hidden = true
        
        leMonde.hidden = false
        leMonde.alpha = 1
        cadreNoir.hidden = true
        cadreNoirJeu.hidden = true
        
        var niveauDansLeMonde = swiftris.level%96
        if swiftris.level == 96 || swiftris.level == 192 || swiftris.level == 288 {
            niveauDansLeMonde = 96
        }
        var quelLointain:Int = Int((2860/96)*niveauDansLeMonde)
        leMonde.contentOffset = CGPoint(x: 0, y: quelLointain)
        
        if swiftris.level > niveauAtteint && swiftris.level < 97 {
            degageLent(cadreCadeau)
        }

        if swiftris.level == 145 {
            cadreNoir.hidden = false
            boutonGlisse(histoireSansFinBouton)
            histoireSansFinLabel.text = NSLocalizedString("HISTOIRE_B",comment:"A step closer to the Ultimate Massicot!")
            arriveVite(cadreHistoireSansFin)
        }
        if swiftris.level > 97 && swiftris.level != 193 && swiftris.level != 145 && swiftris.level != 288 {
            cadreNoir.hidden = false
            let imgper01 = UIImage(named: "perso01pirate.png") as UIImage?
            let imgper02 = UIImage(named: "perso02mouette.png") as UIImage?
            let imgper03 = UIImage(named: "perso03doge.png") as UIImage?
            let imgper04 = UIImage(named: "perso04robot.png") as UIImage?
            let imgper05 = UIImage(named: "perso05reine.png") as UIImage?
            let imgper06 = UIImage(named: "perso06boss.png") as UIImage?
            let imgper07 = UIImage(named: "perso07elena.png") as UIImage?
            let imgper08 = UIImage(named: "perso08panda.png") as UIImage?
            switch Int(arc4random_uniform(5)) {
            case 0:
                rankPerso1.image = imgper03
                rankPerso2.image = imgper04
                rankPerso3.image = imgper06
                rankPerso4.image = imgper07
                rankPerso5.image = imgper02
            case 1:
                rankPerso1.image = imgper03
                rankPerso2.image = imgper02
                rankPerso3.image = imgper08
                rankPerso4.image = imgper04
                rankPerso5.image = imgper05
            case 2:
                rankPerso1.image = imgper06
                rankPerso2.image = imgper05
                rankPerso3.image = imgper02
                rankPerso4.image = imgper01
                rankPerso5.image = imgper03
            case 3:
                rankPerso1.image = imgper01
                rankPerso2.image = imgper03
                rankPerso3.image = imgper04
                rankPerso4.image = imgper05
                rankPerso5.image = imgper06
            case 4:
                rankPerso1.image = imgper04
                rankPerso2.image = imgper01
                rankPerso3.image = imgper06
                rankPerso4.image = imgper02
                rankPerso5.image = imgper03
            default:
                rankPerso1.image = imgper03
                rankPerso2.image = imgper04
                rankPerso3.image = imgper06
                rankPerso4.image = imgper07
                rankPerso5.image = imgper02
            }
            rankLabel1.text = String(Int(2000+arc4random_uniform(1000)))
            rankLabel2.text = String(Int(1500+arc4random_uniform(500)))
            rankLabel3.text = String(Int(1000+arc4random_uniform(500)))
            rankLabel4.text = String(Int(500+arc4random_uniform(600)))
            rankLabel5.text = String(Int(100+arc4random_uniform(500)))
            
            let monScore = Int(scoreProvisoire)
            let maPhoto = profilPhoto.image
            if monScore > 2000 {
                rankPerso1.image = maPhoto
                rankLabel1.text = String(monScore)
            } else if monScore > 1500 && monScore < 2001 {
                rankPerso2.image = maPhoto
                rankLabel2.text = String(monScore)
            } else if monScore > 1000 && monScore < 1501 {
                rankPerso3.image = maPhoto
                rankLabel3.text = String(monScore)
            } else if monScore > 500 && monScore < 1001 {
                rankPerso4.image = maPhoto
                rankLabel4.text = String(monScore)
            } else {
                rankPerso5.image = maPhoto
                rankLabel5.text = String(monScore)
            }
            arriveVite(cadreRank)
        }
        swiftris.score += gainCumule
        sauvegarde.setInteger(swiftris.score, forKey: "argentBanque")
        scoreLabel.text = "\(swiftris.score)"
        gainCumule = 0
        tempsPartie = 0
        tempsMis = 0
    }
    
    func cestParti(sender:UIButton!){
        degageCote(cadreHaut)
        disparaitVite(leMonde)
        cadreNoir.hidden = true
        cadeau1Label.text = "\(swiftris.cadeau1)"
        cadeau3Label.text = "\(swiftris.cadeau2)"
        cadeau2Label.text = "\(swiftris.cadeau3)"
        swiftris.beginGame()
        let sauvekipeu = NSUserDefaults.standardUserDefaults()
        nombreMatches += 1
        sauvekipeu.setInteger(nombreMatches, forKey: "matchesBanque")
        
    }
    func boosterOn(sender:UIButton!){
    }
    func transHistoire(sender:UIButton!){
        degageMenu1(cadreHistoire1)
        arriveVite(cadreHistoire2)
    }
    
    func aBienAchete(collectionIndex: Int) {
        if collectionIndex == 2 {
            degageMenu1(cadreWait)
            cadreNoirJeu.hidden = true
            onceRefill = 0
            if modePoints == 3 {
                compteur = 100
                let compteurFoisDeux:Int = Int((120-compteur)/2)
                compteurLabel.text = String(compteurFoisDeux)+"s"
                barreBoost.frame.size.height -= 1.25
                barreBoost.frame.origin.y += 1.25
                swiftris.beginGame()
            } else if modePoints == 2 {
                swiftris.beginGame()
            } else {
                compteur = 25
                compteurLabel.text = String(30-compteur)
                barreBoost.frame.size.height = CGFloat(150-(compteur*5))
                barreBoost.frame.origin.y = 45+CGFloat(compteur*5)
                swiftris.beginGame()
            }
        }
        else {
            onceRefill = 0
        }
    }
    
    
    override func viewDidLoad() {
        var enregistRements: AnyObject? = NSUserDefaults()
        super.viewDidLoad()
        
        UIApplication.sharedApplication().idleTimerDisabled = true
        
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        
        let skView = view as! SKView
        skView.multipleTouchEnabled = false
        
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        
        scene.tick = didTick
        
        swiftris = Swiftris()
        swiftris.delegate = self
        
        skView.presentScene(scene)
        
        cadreFleurs.hidden = true
        cadreJardin.hidden = true
        
        cadreJoujou.hidden = true
        cadreJeu.hidden = true
        cadreWin.hidden = true
        cadreLose.hidden = true
        cadreCadeau.hidden = true
        cadreWait.hidden = true
        barreBas.hidden = true
        barreHaut.hidden = true
        fondVert.hidden = true
        fondRouge.hidden = true
        cadreHaut.hidden = true
        cadreHistoire1.hidden = true
        cadreHistoire2.hidden = true
        cadreConfirm.hidden = true
        cadrePresque.hidden = true
        barreBasMenu.hidden = true
        cadreAbout.hidden = true
        cadreShop.hidden = true
        shopValide.hidden = true
        cadreProfil.hidden = true
        cadreLangues.hidden = true
        cadrePersos.hidden = true
        cadreRank.hidden = true
        cadreHistoireSansFin.hidden = true
        cadreCharge.hidden = true
        taler1.hidden = true
        taler2.hidden = true
        taler3.hidden = true
        taler4.hidden = true
        taler5.hidden = true
        taler6.hidden = true
        taler7.hidden = true
        taler8.hidden = true
        taler9.hidden = true
        taler10.hidden = true
        cadreNoirJeu.hidden = true
        cadreStars.hidden = true
        cadreBourse.hidden = true
        cadreReseau.hidden = true
        rond1.tag = 1
        rond2.tag = 2
        rond3.tag = 3
        rond4.tag = 4
        rond5.tag = 5
        rond6.tag = 6
        rond7.tag = 7
        rond8.tag = 8
        rond9.tag = 9
        rond10.tag = 10
        rond11.tag = 11
        rond12.tag = 12
        rond13.tag = 13
        rond14.tag = 14
        rond15.tag = 15
        rond16.tag = 16
        rond17.tag = 17
        rond18.tag = 18
        rond19.tag = 19
        rond20.tag = 20
        rond21.tag = 21
        rond22.tag = 22
        rond23.tag = 23
        rond24.tag = 24
        rond25.tag = 25
        rond26.tag = 26
        rond27.tag = 27
        rond28.tag = 28
        rond29.tag = 29
        rond30.tag = 30
        rond31.tag = 31
        rond32.tag = 32
        rond33.tag = 33
        rond34.tag = 34
        rond35.tag = 35
        rond36.tag = 36
        rond37.tag = 37
        rond38.tag = 38
        rond39.tag = 39
        rond40.tag = 40
        rond41.tag = 41
        rond42.tag = 42
        rond43.tag = 43
        rond44.tag = 44
        rond45.tag = 45
        rond46.tag = 46
        rond47.tag = 47
        rond48.tag = 48
        rond49.tag = 49
        rond50.tag = 50
        rond51.tag = 51
        rond52.tag = 52
        rond53.tag = 53
        rond54.tag = 54
        rond55.tag = 55
        rond56.tag = 56
        rond57.tag = 57
        rond58.tag = 58
        rond59.tag = 59
        rond60.tag = 60
        rond61.tag = 61
        rond62.tag = 62
        rond63.tag = 63
        rond64.tag = 64
        rond65.tag = 65
        rond66.tag = 66
        rond67.tag = 67
        rond68.tag = 68
        rond69.tag = 69
        rond70.tag = 70
        rond71.tag = 71
        rond72.tag = 72
        rond73.tag = 73
        rond74.tag = 74
        rond75.tag = 75
        rond76.tag = 76
        rond77.tag = 77
        rond78.tag = 78
        rond79.tag = 79
        rond80.tag = 80
        rond81.tag = 81
        rond82.tag = 82
        rond83.tag = 83
        rond84.tag = 84
        rond85.tag = 85
        rond86.tag = 86
        rond87.tag = 87
        rond88.tag = 88
        rond89.tag = 89
        rond90.tag = 90
        rond91.tag = 91
        rond92.tag = 92
        rond93.tag = 93
        rond94.tag = 94
        rond95.tag = 95
        rond96.tag = 96
        
        achat1.tag = 1001
        achat2.tag = 1002
        achat3.tag = 1003
        achat4.tag = 1004
        achat5.tag = 1005
        achat6.tag = 1006
        achat7.tag = 1007
        achat8.tag = 1008
        achat9.tag = 1009
        porteMondeBas.tag = 900
        porteMondeHaut.tag = 901
        
        profilMedal1.tag = 2001
        profilMedal2.tag = 2002
        profilMedal3.tag = 2003
        profilMedal4.tag = 2004
        profilMedal5.tag = 2005
        profilMedal6.tag = 2006
        profilMedal7.tag = 2007
        profilMedal8.tag = 2008
        profilMedal9.tag = 2009
        profilMedal10.tag = 2010
        profilMedal11.tag = 2011
        profilMedal12.tag = 2012
        
        boutonBouge(histoireMain)
        boutonBouge(flecheHistoire)
        
        boutonCestParti.addTarget(self, action: "cestParti:", forControlEvents:.TouchUpInside)
        boutonBooster.addTarget(self, action: "boosterOn:", forControlEvents:.TouchUpInside)
        flecheHistoire.addTarget(self, action: "transHistoire:", forControlEvents:.TouchUpInside)
        boutonduDebut.addTarget(self, action: "boutonDebut:", forControlEvents:.TouchUpInside)
        rond1.addTarget(self, action: "boutonEpisode:", forControlEvents:.TouchUpInside)
        boutonPasContinue.addTarget(self, action: "gameFoutu:", forControlEvents:.TouchUpInside)
        boutonContinue.addTarget(self, action: "continuerPayer:", forControlEvents:.TouchUpInside)
        boutonMenuAbout.addTarget(self, action: "ouvreAbout:", forControlEvents:.TouchUpInside)
        boutonMenuShop.addTarget(self, action: "ouvreShop:", forControlEvents:.TouchUpInside)
        boutonQuitShop.addTarget(self, action: "quitteShop:", forControlEvents:.TouchUpInside)
        boutonMenuQuitter.addTarget(self, action: "ouvreProfil:", forControlEvents:.TouchUpInside)
        boutonSon.addTarget(self, action: "changerSon:", forControlEvents:.TouchUpInside)
        boutonLangue.addTarget(self, action: "choisirLangue:", forControlEvents:.TouchUpInside)
        porteMondeBas.addTarget(self, action: "passerPorteBas:", forControlEvents:.TouchUpInside)
        porteMondeHaut.addTarget(self, action: "passerPorteHaut:", forControlEvents:.TouchUpInside)
        mondeSoleil.addTarget(self, action: "ouvreJardin:", forControlEvents:.TouchUpInside)
        histoireSansFinBouton.addTarget(self, action: "quitterHSF:", forControlEvents:.TouchUpInside)
        boutondefleur.addTarget(self, action: "floraison:", forControlEvents:.TouchUpInside)
        boutonCadeauTombe.addTarget(self, action: "chargerWin:", forControlEvents:.TouchUpInside)
        speedUpSommeil.addTarget(self, action: "speedUpBouton:", forControlEvents:.TouchUpInside)

        if(SKPaymentQueue.canMakePayments()) {
            print("IAP is enabled, loading")
            var productID:NSSet = NSSet(objects: "com.emg.Massicot.lives", "com.emg.Massicot.littlehelp", "com.emg.Massicot.extracash")
            var request: SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>)
            request.delegate = self
            request.start()
        } else {
            print("please enable IAPS")
        }
        
        for var nummer = 1001; nummer < 1010; ++nummer {
            let boutonsAchat = self.view.viewWithTag(nummer) as? UIButton
            boutonsAchat?.addTarget(self, action: "achatN1:", forControlEvents:.TouchUpInside)
        }
        
        boutonGrossit(boutonduDebut)
        boutonGrossit(mondeSoleil)
        boutonGlisse(mondeNuage)
        boutonGlisse(mondeBoot)
        boutonGlisse(mondeZep)
        boutonGrossit(porteMondeHaut)
        boutonGrossit(porteMondeBas)
        
        leMonde.hidden = true
        cadreNoir.hidden = true
        
        let path = NSBundle.mainBundle().URLForResource("brahms", withExtension: "mp3")
        var error:NSError?
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOfURL: path!)
        } catch let error1 as NSError {
            error = error1
        } catch {
            print("une connerie")
        }
        audioPlayer.numberOfLoops = -1
        
        ///deuxieme player
        
        let pathJeu = NSBundle.mainBundle().URLForResource("pourlefun", withExtension: "mp3")
        var errorJeu:NSError?
        
        do {
            audioJeu = try AVAudioPlayer(contentsOfURL: pathJeu!)
        } catch let error1Jeu as NSError {
            errorJeu = error1Jeu
        } catch {
            print("une connerie")
        }
        audioJeu.numberOfLoops = -1

        
        //var alertSound = NSURL(fileURLWithPath: "theme1.mp3")
        //println(alertSound)

        //AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        //AVAudioSession.sharedInstance().setActive(true, error: nil)
        // AH AH AH I MADE IT
        //var error:NSError?
        //audioPlayer = AVAudioPlayer(contentsOfURL: alertSound, error: &error)
        //audioPlayer.prepareToPlay()
        //audioPlayer.play()
        
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func didTick() {
        swiftris.letShapeFall()
    }
    
    func nextShape() {
        let newShapes = swiftris.newShape()
        if let fallingShape = newShapes.fallingShape {
            self.scene.addPreviewShapeToScene(newShapes.nextShape!) {}
            self.scene.movePreviewShape(fallingShape) {
                self.view.userInteractionEnabled = true
                self.scene.startTicking()
            }
        }
    }
    
    func nouveauNiveau() {
        
        onceRefill = 0
        
        let fond1Grass = UIImage(named: "fond1grass.png") as UIImage?
        let fond2Mountain = UIImage(named: "fond2mountain.png") as UIImage?
        let fond3Desert = UIImage(named: "fond3desert.png") as UIImage?
        let fond4Forest = UIImage(named: "fond4forest.png") as UIImage?
        let fond5City = UIImage(named: "fond5city.png") as UIImage?
        let fond6Mer = UIImage(named: "fond6mer.png") as UIImage?
        
        let reste = (swiftris.level)%3
        let resteMode = (swiftris.level)%4
        let reste2 = ((swiftris.level)-1)%3
        let resteMode2 = ((swiftris.level)-1)%4
        let epizode = ((swiftris.level)-1-reste2)/3
        
        switch epizode {
        case 0:
            lotEpisode = "ecolenew"
        case 1:
            lotEpisode = "cookienew"
        case 2:
            lotEpisode = "foretnew"
        case 3:
            lotEpisode = "fermenew"
        case 4:
            lotEpisode = "sportnew"
        case 5:
            lotEpisode = "tournoinew"
        case 6:
            lotEpisode = "minenew"
        case 7:
            lotEpisode = "chatonew"
        case 8:
            lotEpisode = "letnew"
        case 9:
            lotEpisode = "jeu"
        case 10:
            lotEpisode = "shop"
        case 11:
            lotEpisode = "champion"
        case 12:
            lotEpisode = "oiseau"
        case 13:
            lotEpisode = "mer"
        case 14:
            lotEpisode = "merde"
        case 15:
            lotEpisode = "art"
        case 16:
            lotEpisode = "ny"
        case 17:
            lotEpisode = "mandala"
        case 18:
            lotEpisode = "glace"
        case 19:
            lotEpisode = "mossi"
        case 20:
            lotEpisode = "doge"
        case 21:
            lotEpisode = "aus"
        case 22:
            lotEpisode = "shan"
        case 23:
            lotEpisode = "drap"
        case 24:
            lotEpisode = "arab"
        case 25:
            lotEpisode = "maya"
        case 26:
            lotEpisode = "jv"
        case 27:
            lotEpisode = "tron"
        case 28:
            lotEpisode = "jeu"
        case 29:
            lotEpisode = "echec"
        case 30:
            lotEpisode = "laby"
        case 31:
            lotEpisode = "epreuve"
        case 32:
            lotEpisode = "gt"
        case 33:
            lotEpisode = "gs"
        case 34:
            lotEpisode = "gt"
        case 35:
            lotEpisode = "gs"
        case 36:
            lotEpisode = "gt"
        case 37:
            lotEpisode = "gu"
        case 38:
            lotEpisode = "gv"
        case 39:
            lotEpisode = "gu"
        case 40:
            lotEpisode = "gv"
        case 41:
            lotEpisode = "gu"
        case 42:
            lotEpisode = "gw"
        case 43:
            lotEpisode = "gx"
        case 44:
            lotEpisode = "gw"
        case 45:
            lotEpisode = "gx"
        case 46:
            lotEpisode = "gw"
        case 47:
            lotEpisode = "gy"
        case 48:
            lotEpisode = "gz"
        case 49:
            lotEpisode = "gy"
        case 50:
            lotEpisode = "gz"
        case 51:
            lotEpisode = "gy"
        case 52:
            lotEpisode = "go"
        case 53:
            lotEpisode = "gr"
        case 54:
            lotEpisode = "go"
        case 55:
            lotEpisode = "gr"
        case 56:
            lotEpisode = "go"
        case 57:
            lotEpisode = "gm"
        case 58:
            lotEpisode = "gd"
        case 59:
            lotEpisode = "gm"
        case 60:
            lotEpisode = "gd"
        case 61:
            lotEpisode = "gm"
        case 62:
            lotEpisode = "ge"
        case 63:
            lotEpisode = "gf"
        case 64:
            lotEpisode = "ge"
        case 65:
            lotEpisode = "gf"
        case 66:
            lotEpisode = "ge"
        case 67:
            lotEpisode = "gg"
        case 68:
            lotEpisode = "gh"
        case 69:
            lotEpisode = "gg"
        case 70:
            lotEpisode = "gh"
        case 71:
            lotEpisode = "gg"
        case 72:
            lotEpisode = "gi"
        case 73:
            lotEpisode = "gj"
        case 74:
            lotEpisode = "gi"
        case 75:
            lotEpisode = "gj"
        case 76:
            lotEpisode = "gi"
        case 77:
            lotEpisode = "gk"
        case 78:
            lotEpisode = "gl"
        case 79:
            lotEpisode = "gk"
        case 80:
            lotEpisode = "gl"
        case 81:
            lotEpisode = "gk"
        case 82:
            lotEpisode = "mandala"
        case 83:
            lotEpisode = "gn"
        case 84:
            lotEpisode = "jv"
        case 85:
            lotEpisode = "gn"
        case 86:
            lotEpisode = "merde"
        case 87:
            lotEpisode = "jv"
        case 88:
            lotEpisode = "glace"
        case 89:
            lotEpisode = "shan"
        case 90:
            lotEpisode = "glace"
        case 91:
            lotEpisode = "fermenew"
        case 92:
            lotEpisode = "gt"
        case 93:
            lotEpisode = "gu"
        case 94:
            lotEpisode = "gf"
        case 95:
            lotEpisode = "ge"
        default:
            lotEpisode = "minenew"
        }
        var nomVille = String(lotEpisode)+"b4a.png"
        
        switch reste {
        case 0:
            nomVille = String(lotEpisode)+"c1c.png"
        case 1:
            nomVille = String(lotEpisode)+"a4a.png"
        case 2:
            nomVille = String(lotEpisode)+"b4b.png"
        default:
            nomVille = String(lotEpisode)+"b3c.png"
        }
        
        if (epizode ==  31 || epizode ==  30 || epizode ==  29 || epizode ==  27 || epizode ==  25 || epizode ==  24 || epizode ==  22 || epizode ==  16 || epizode ==  15) && reste == 0 {
            nomVille = String(lotEpisode)+"b1c.png"
        }
        
        if (epizode == 35 || epizode ==  40 || epizode ==  45 || epizode ==  50 || epizode ==  55 || epizode ==  60 || epizode ==  65 || epizode ==  70 || epizode ==  75 || epizode ==  80) || (epizode > 85 && epizode < 96){
            nomVille = "menuabout.png"
            }
        
        if (epizode == 2) || (epizode > 53 && epizode < 60) || (epizode > 83 && epizode < 88) {
            fondecran.image = fond4Forest
        } else if (epizode > 31 && epizode < 37) || (epizode == 15) || (epizode == 16) || (epizode == 22) {
            fondecran.image = fond5City
        } else if epizode > 59 && epizode < 79 || (epizode == 24) || (epizode == 25) {
            fondecran.image = fond3Desert
        } else if (epizode == 17) || (epizode > 78 && epizode < 84) || (epizode > 26 && epizode < 32) {
            fondecran.image = fond2Mountain
        } else if (epizode > 11 && epizode < 15) || (epizode > 36 && epizode < 48) {
            fondecran.image = fond6Mer
        } else {
            fondecran.image = fond1Grass
        }

        let tournoi = UIImage(named: nomVille) as UIImage?
        let cutMode0 = UIImage(named: "cut0b.png") as UIImage?
        let cutMode1 = UIImage(named: "cut1b.png") as UIImage?
        let cutMode2 = UIImage(named: "cut2.png") as UIImage?
        let modePoints0 = UIImage(named: "modepoints0.png") as UIImage?
        let modePoints2 = UIImage(named: "jaugenotime.png") as UIImage?
        let modePoints3 = UIImage(named: "modepoints3.png") as UIImage?
        let modePoints4 = UIImage(named: "modepoints4.png") as UIImage?
        medaillon.image = tournoi;
        levelLabel.text = "\(swiftris.level)"
        scoreLabel.text = "\(swiftris.score)"
        cityLabel.text = "\(swiftris.city)"
        viesLabel.text = "\(swiftris.vies)"
        
        let imageBoutonBoosterOk = UIImage(named: "jaugevert.png") as UIImage?
        let imageBoutonBoosterTemps = UIImage(named: "modepoints3.png") as UIImage?
        let imageBoutonBoosterMatch = UIImage(named: "jaugesouris.png") as UIImage?
        let imageBoutonBoosterVide = UIImage(named: "jaugevide.png") as UIImage?
        let imageBoutonBoosterError = UIImage(named: "jaugenotime.png") as UIImage?
        let imageBanniereMode2 = UIImage(named: "bannieremp2.png") as UIImage?
        let imageBanniereMode4 = UIImage(named: "bannieremp4.png") as UIImage?
        let boutonsBleu = UIImage(named: "boutonsbleu.png") as UIImage?
        
        let imgperso01 = UIImage(named: "perso16chat.png") as UIImage?
        let imgperso02 = UIImage(named: "perso17dog.png") as UIImage?
        let imgperso03 = UIImage(named: "perso14afro.png") as UIImage?
        let imgperso04 = UIImage(named: "perso11girl.png") as UIImage?
        let imgperso05 = UIImage(named: "perso12gi.png") as UIImage?
        let imgperso06 = UIImage(named: "perso09harry.png") as UIImage?
        let imgperso07 = UIImage(named: "perso15woody.png") as UIImage?
        let imgperso08 = UIImage(named: "perso10souris.png") as UIImage?
        let imgperso09 = UIImage(named: "perso13fantome.png") as UIImage?
        switch persoChoisi {
        case 0:
            boutonBooster2.setBackgroundImage(imgperso01, forState: .Normal)
        case 1:
            boutonBooster2.setBackgroundImage(imgperso02, forState: .Normal)
        case 2:
            boutonBooster2.setBackgroundImage(imgperso03, forState: .Normal)
        case 3:
            boutonBooster2.setBackgroundImage(imgperso04, forState: .Normal)
        case 4:
            boutonBooster2.setBackgroundImage(imgperso05, forState: .Normal)
        case 5:
            boutonBooster2.setBackgroundImage(imgperso06, forState: .Normal)
        case 6:
            boutonBooster2.setBackgroundImage(imgperso07, forState: .Normal)
        case 7:
            boutonBooster2.setBackgroundImage(imgperso08, forState: .Normal)
        case 8:
            boutonBooster2.setBackgroundImage(imgperso09, forState: .Normal)
        default:
            boutonBooster2.setBackgroundImage(imgperso01, forState: .Normal)
        }
        
        perfectLabel.hidden = true
        tempsLabel.text = "0"
        
        switch resteMode {
        case 0:
            modePoints = 3
            medaillonModePoints.image = modePoints3
            boutonBooster.setBackgroundImage(imageBoutonBoosterTemps, forState: .Normal)
            banniereMode.image = imageBoutonBoosterVide
            petitFondBleu1.image  = boutonsBleu
            petitFondBleu2.image  = boutonsBleu
            cityLabel.text = NSLocalizedString("MODE_TEMPS",comment:"Get 100 coins in less than 60 seconds.")
        case 1:
            modePoints = 0
            medaillonModePoints.image = modePoints0
            boutonBooster.setBackgroundImage(imageBoutonBoosterOk, forState: .Normal)
            banniereMode.image = imageBoutonBoosterVide
            petitFondBleu1.image  = boutonsBleu
            petitFondBleu2.image  = boutonsBleu
            cityLabel.text = NSLocalizedString("MODE_COINS",comment:"Get 100 coins in less than 30 rounds. Be fast enough!")
        case 2:
            modePoints = 2
            medaillonModePoints.image = modePoints2
            boutonBooster.setBackgroundImage(imageBoutonBoosterError, forState: .Normal)
            banniereMode.image = imageBanniereMode2
            petitFondBleu1.image  = imageBoutonBoosterVide
            petitFondBleu2.image  = imageBoutonBoosterVide
            cityLabel.text = NSLocalizedString("MODE_ERREUR",comment:"Solve 30 Massicots without any error.")
        case 3:
            modePoints = 1
            medaillonModePoints.image = modePoints0
            boutonBooster.setBackgroundImage(imageBoutonBoosterOk, forState: .Normal)
            banniereMode.image = imageBoutonBoosterVide
            petitFondBleu1.image  = boutonsBleu
            petitFondBleu2.image  = boutonsBleu
            cityLabel.text = NSLocalizedString("MODE_COINS",comment:"Get 100 coins in less than 30 rounds. Be fast enough!")
        default:
            modePoints = 0
            medaillonModePoints.image = modePoints0
            boutonBooster.setBackgroundImage(imageBoutonBoosterOk, forState: .Normal)
            banniereMode.image = imageBoutonBoosterVide
            petitFondBleu1.image  = boutonsBleu
            petitFondBleu2.image  = boutonsBleu
            cityLabel.text = NSLocalizedString("MODE_COINS",comment:"Get 100 coins in less than 30 rounds. Be fast enough!")
        }
        
        gainLabel.hidden = true
        barreBoost.hidden = false
        barreBoost.backgroundColor = UIColor.greenColor()
        barreBoost2.hidden = true
        barreBoost.frame = CGRectMake(288, 45, 20, 150)
        compteurLabel.hidden = false
        
        if modePoints == 3 {
            compteurLabel.text = "60s"
            barreBoost.backgroundColor = UIColor.yellowColor()
        } else {
            compteurLabel.text = "30"
        }
        
        if modePoints == 2 {
            tempsLabel.hidden = true
            barreBoost.backgroundColor = UIColor.redColor()
        } else {
            tempsLabel.hidden = false
        }
        
        if resteMode == 3 {
            modePoints = 4
            medaillonModePoints.image = modePoints4
            boutonBooster.setBackgroundImage(imageBoutonBoosterMatch, forState: .Normal)
            banniereMode.image = imageBanniereMode4
            petitFondBleu1.image  = imageBoutonBoosterVide
            petitFondBleu2.image  = imageBoutonBoosterVide
            barreBoost2.hidden = false
            barreBoost.frame = CGRectMake(288, 195, 20, 1)
            barreBoost.backgroundColor = UIColor.yellowColor()
            barreBoost2.frame = CGRectMake(12, 195, 20, 1)
            compteurLabel.hidden = true
            cityLabel.text = NSLocalizedString("MODE_BATTLE",comment:"Get 100 coins before your opponent does.")
        }
        
        switch reste {
        case 0:
            modeJeu = 2
            medaillonMode.image = cutMode2
        case 1:
            modeJeu = 0
            medaillonMode.image = cutMode0
        case 2:
            modeJeu = 1
            medaillonMode.image = cutMode1
        default:
            modeJeu = 0
            medaillonMode.image = cutMode0
        }
        
        let caDependPerso:Int = Int(arc4random_uniform(17))
        let imgperzo01 = UIImage(named: "perso01pirate.png") as UIImage?
        let imgperzo02 = UIImage(named: "perso02mouette.png") as UIImage?
        let imgperzo03 = UIImage(named: "perso03doge.png") as UIImage?
        let imgperzo04 = UIImage(named: "perso04robot.png") as UIImage?
        let imgperzo05 = UIImage(named: "perso05reine.png") as UIImage?
        let imgperzo06 = UIImage(named: "perso06boss.png") as UIImage?
        let imgperzo07 = UIImage(named: "perso07elena.png") as UIImage?
        let imgperzo08 = UIImage(named: "perso08panda.png") as UIImage?
        let imgperzo09 = UIImage(named: "perso09harry.png") as UIImage?
        let imgperzo10 = UIImage(named: "perso10souris.png") as UIImage?
        let imgperzo11 = UIImage(named: "perso16chat.png") as UIImage?
        let imgperzo12 = UIImage(named: "perso17dog.png") as UIImage?
        let imgperzo13 = UIImage(named: "perso14afro.png") as UIImage?
        let imgperzo14 = UIImage(named: "perso11girl.png") as UIImage?
        let imgperzo15 = UIImage(named: "perso12gi.png") as UIImage?
        let imgperzo17 = UIImage(named: "perso15woody.png") as UIImage?
        let imgperzo16 = UIImage(named: "perso13fantome.png") as UIImage?
        
        if resteMode == 3 && caDependPerso == 1 {
            medaillonModePoints.image = imgperzo01
            boutonBooster.setBackgroundImage(imgperzo01, forState: .Normal)
        } else if resteMode == 3 && caDependPerso == 2 {
            medaillonModePoints.image = imgperzo02
            boutonBooster.setBackgroundImage(imgperzo02, forState: .Normal)
        } else if resteMode == 3 && caDependPerso == 3 {
            medaillonModePoints.image = imgperzo03
            boutonBooster.setBackgroundImage(imgperzo03, forState: .Normal)
        } else if resteMode == 3 && caDependPerso == 4 {
            medaillonModePoints.image = imgperzo04
            boutonBooster.setBackgroundImage(imgperzo04, forState: .Normal)
        } else if resteMode == 3 && caDependPerso == 5 {
            medaillonModePoints.image = imgperzo05
            boutonBooster.setBackgroundImage(imgperzo05, forState: .Normal)
        } else if resteMode == 3 && caDependPerso == 6 {
            medaillonModePoints.image = imgperzo06
            boutonBooster.setBackgroundImage(imgperzo06, forState: .Normal)
        } else if resteMode == 3 && caDependPerso == 7 {
            medaillonModePoints.image = imgperzo07
            boutonBooster.setBackgroundImage(imgperzo07, forState: .Normal)
        } else if resteMode == 3 && caDependPerso == 8 {
            medaillonModePoints.image = imgperzo08
            boutonBooster.setBackgroundImage(imgperzo08, forState: .Normal)
        } else if resteMode == 3 && caDependPerso == 9 && persoChoisi == 5 {
            medaillonModePoints.image = imgperzo11
            boutonBooster.setBackgroundImage(imgperzo11, forState: .Normal)
        } else if resteMode == 3 && caDependPerso == 9 {
            medaillonModePoints.image = imgperzo09
            boutonBooster.setBackgroundImage(imgperzo09, forState: .Normal)
        } else if resteMode == 3 && caDependPerso == 10 && persoChoisi == 7 {
            medaillonModePoints.image = imgperzo11
            boutonBooster.setBackgroundImage(imgperzo11, forState: .Normal)
        } else if resteMode == 3 && caDependPerso == 10 {
            medaillonModePoints.image = imgperzo10
            boutonBooster.setBackgroundImage(imgperzo10, forState: .Normal)
        } else if resteMode == 3 && caDependPerso == 11 && persoChoisi == 0 {
            medaillonModePoints.image = imgperzo10
            boutonBooster.setBackgroundImage(imgperzo10, forState: .Normal)
        } else if resteMode == 3 && caDependPerso == 11 {
            medaillonModePoints.image = imgperzo11
            boutonBooster.setBackgroundImage(imgperzo11, forState: .Normal)
        } else if resteMode == 3 && caDependPerso == 12 && persoChoisi == 1 {
            medaillonModePoints.image = imgperzo11
            boutonBooster.setBackgroundImage(imgperzo11, forState: .Normal)
        } else if resteMode == 3 && caDependPerso == 12 {
            medaillonModePoints.image = imgperzo12
            boutonBooster.setBackgroundImage(imgperzo12, forState: .Normal)
        } else if resteMode == 3 && caDependPerso == 13 && persoChoisi == 2 {
            medaillonModePoints.image = imgperzo11
            boutonBooster.setBackgroundImage(imgperzo11, forState: .Normal)
        } else if resteMode == 3 && caDependPerso == 13 {
            medaillonModePoints.image = imgperzo13
            boutonBooster.setBackgroundImage(imgperzo13, forState: .Normal)
        } else if resteMode == 3 && caDependPerso == 14 && persoChoisi == 3 {
            medaillonModePoints.image = imgperzo07
            boutonBooster.setBackgroundImage(imgperzo07, forState: .Normal)
        } else if resteMode == 3 && caDependPerso == 14 {
            medaillonModePoints.image = imgperzo14
            boutonBooster.setBackgroundImage(imgperzo14, forState: .Normal)
        } else if resteMode == 3 && caDependPerso == 15 && persoChoisi == 4 {
            medaillonModePoints.image = imgperzo03
            boutonBooster.setBackgroundImage(imgperzo03, forState: .Normal)
        } else if resteMode == 3 && caDependPerso == 15 {
            medaillonModePoints.image = imgperzo15
            boutonBooster.setBackgroundImage(imgperzo15, forState: .Normal)
        } else if resteMode == 3 && caDependPerso == 16 && persoChoisi == 8 {
            medaillonModePoints.image = imgperzo06
            boutonBooster.setBackgroundImage(imgperzo06, forState: .Normal)
        } else if resteMode == 3 && caDependPerso == 16 {
            medaillonModePoints.image = imgperzo16
            boutonBooster.setBackgroundImage(imgperzo16, forState: .Normal)
        } else if resteMode == 3 && caDependPerso == 17 && persoChoisi == 6 {
            medaillonModePoints.image = imgperzo12
            boutonBooster.setBackgroundImage(imgperzo12, forState: .Normal)
        } else if resteMode == 3 && caDependPerso == 17 {
            medaillonModePoints.image = imgperzo17
            boutonBooster.setBackgroundImage(imgperzo17, forState: .Normal)
        } else if resteMode == 3 {
            medaillonModePoints.image = imgperzo01
            boutonBooster.setBackgroundImage(imgperzo01, forState: .Normal)
        }
        
        if resteMode == 3 && swiftris.level == 39 {
            medaillonModePoints.image = imgperzo02
            boutonBooster.setBackgroundImage(imgperzo02, forState: .Normal)
        } else if resteMode == 3 && swiftris.level == 43 {
            medaillonModePoints.image = imgperzo01
            boutonBooster.setBackgroundImage(imgperzo01, forState: .Normal)
        } else if resteMode == 3 && swiftris.level == 47 && persoChoisi == 5 {
            medaillonModePoints.image = imgperzo12
            boutonBooster.setBackgroundImage(imgperzo12, forState: .Normal)
        } else if resteMode == 3 && swiftris.level == 47 {
            medaillonModePoints.image = imgperzo09
            boutonBooster.setBackgroundImage(imgperzo09, forState: .Normal)
        } else if resteMode == 3 && swiftris.level == 55 {
            medaillonModePoints.image = imgperzo07
            boutonBooster.setBackgroundImage(imgperzo07, forState: .Normal)
        } else if resteMode == 3 && swiftris.level == 63 {
            medaillonModePoints.image = imgperzo03
            boutonBooster.setBackgroundImage(imgperzo03, forState: .Normal)
        } else if resteMode == 3 && swiftris.level == 67 {
            medaillonModePoints.image = imgperzo08
            boutonBooster.setBackgroundImage(imgperzo08, forState: .Normal)
        } else if resteMode == 3 && swiftris.level == 79 {
            medaillonModePoints.image = imgperzo04
            boutonBooster.setBackgroundImage(imgperzo04, forState: .Normal)
        } else if resteMode == 3 && swiftris.level == 83 {
            medaillonModePoints.image = imgperzo04
            boutonBooster.setBackgroundImage(imgperzo04, forState: .Normal)
        } else if resteMode == 3 && swiftris.level == 87 {
            medaillonModePoints.image = imgperzo05
            boutonBooster.setBackgroundImage(imgperzo05, forState: .Normal)
        } else if resteMode == 3 && swiftris.level == 91 {
            medaillonModePoints.image = imgperzo06
            boutonBooster.setBackgroundImage(imgperzo06, forState: .Normal)
        }

        tempsMis = 0


    }
    
    func gameDidIntro(swiftris: Swiftris) {
        
        
        barreBas.hidden = true
        
        boutonDeGauche.exclusiveTouch = true
        boutonDuMilieu.exclusiveTouch = true
        boutonDeDroite.exclusiveTouch = true
        
        nouveauNiveau()
        
    }
    
    func boutonBouge(view: UIView){
        let cadreTruc = view.frame
        UIView.animateWithDuration(0.6, delay: 0.0, options: [.Repeat, .Autoreverse, .AllowUserInteraction], animations: {
            var cadreMachin = view.frame
            cadreMachin.origin.y -= 13
            view.frame = cadreMachin
            }, completion: { finished in
                view.frame = cadreTruc
        })
    }
    
    func boutonVole1(view: UIView){
        view.hidden = false
        view.alpha = 1.0
        let TopFame = view.frame
        view.frame.origin.y += 3*(TopFame.size.height)
        UIView.animateWithDuration(1, delay: 0.2, options: .CurveEaseOut, animations: {
            var basketTopFrame = view.frame
            basketTopFrame.origin.y -= 3*(basketTopFrame.size.height)
            view.frame = basketTopFrame
            }, completion: { finished in
                print("boutonvole1")
        })
    }
    
    func boutonGrossit(view: UIView){
        let cadreTruc = view.frame
        UIView.animateWithDuration(0.6, delay: 0.0, options: [.Repeat, .Autoreverse, .AllowUserInteraction], animations: {
            let cadreMachin = view.frame
            view.transform = CGAffineTransformMakeScale(0.97, 0.94)
            view.frame = cadreMachin
            }, completion: { finished in
                view.frame = cadreTruc
        })
    }
    
    func boutonGlisse(view: UIView){
        let cadreTruc = view.frame
        UIView.animateWithDuration(1.5, delay: 0.0, options: [.Repeat, .Autoreverse, .AllowUserInteraction], animations: {
            var cadreMachin = view.frame
            cadreMachin.origin.x -= 7
            view.frame = cadreMachin
            }, completion: { finished in
                view.frame = cadreTruc
        })
    }
    
    func degageMenu1(view: UIView){
        view.hidden = false
        view.alpha = 1.0
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseIn, animations: {
            view.alpha = 0.0
            }, completion: { finished in
                view.hidden = true
        })
    }
    
    func disparaitVite(view: UIView){
        view.hidden = false
        view.alpha = 1.0
        UIView.animateWithDuration(0.4, delay: 0.3, options: .CurveEaseOut, animations: {
            var basketTopFrame = view.frame
            view.alpha = 0.0
            
            }, completion: { finished in
                view.hidden = true
        })
    }
    
    func disparaitDelai(view: UIView){
        view.hidden = false
        view.alpha = 1.0
        UIView.animateWithDuration(0.8, delay: 4, options: .CurveEaseOut, animations: {
            var basketTopFrame = view.frame
            view.alpha = 0.0
            
            }, completion: { finished in
                view.hidden = true
                
        })
    }
    
    func disparaitDelai2(view: UIView){
        view.hidden = false
        view.alpha = 1.0
        UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseOut, animations: {
            var basketTopFrame = view.frame
            view.alpha = 0.0
            
            }, completion: { finished in
                view.hidden = true
                self.vraiDebut()
                
        })
    }
    
    func transitionPorteLoad(view: UIView){
        view.hidden = false
        view.alpha = 1.0
        UIView.animateWithDuration(0.8, delay: 1, options: .CurveEaseOut, animations: {
            var basketTopFrame = view.frame
            view.alpha = 0.0
            
            }, completion: { finished in
                view.hidden = true
                
        })
    }
    
    func transitionPorteHaute(view: UIView){
        view.hidden = false
        view.alpha = 1.0
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut, animations: {
            var basketTopFrame = view.frame
            view.alpha = 0.0
            
            }, completion: { finished in
                view.hidden = true
                self.passerPH()
                
        })
    }
    
    func transitionPorteBasse(view: UIView){
        view.hidden = false
        view.alpha = 1.0
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut, animations: {
            var basketTopFrame = view.frame
            view.alpha = 0.0
            
            }, completion: { finished in
                view.hidden = true
                self.passerPB()
                
        })
    }
    
    func degageMenu2(view: UIView){
        view.hidden = false
        view.alpha = 1.0
        var basketTopFrame = view.frame
        basketTopFrame.origin.y -= 2*(basketTopFrame.size.height)
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: {
            var basketTopFrame = view.frame
            basketTopFrame.origin.y += 2*(basketTopFrame.size.height)
            
            view.frame = basketTopFrame
            
            }, completion: { finished in
                view.hidden = false
                print("cool thing!")
        })
    }
    
    func degageCote(view: UIView){
        view.hidden = false
        view.alpha = 1.0
        var ancienCadre = view.frame
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: {
            var leCadre = view.frame
            leCadre.origin.x -= 3*(leCadre.size.width)
            }, completion: { finished in
                print("par la droite!")
                var ancienCadre = view.frame
                view.hidden = true
                ancienCadre.origin.x += 3*(ancienCadre.size.width)
        })
    }
    
    func degageLent(view: UIView){
        view.hidden = false
        view.alpha = 1.0
        UIView.animateWithDuration(0.2, delay: 2.0, options: .CurveEaseIn, animations: {
            view.alpha = 0.0
            
            }, completion: { finished in
                view.hidden = false
                print("degageLent")
        })
    }
    
    func arriveLent(view: UIView){
        view.hidden = false
        view.alpha = 1.0
        let TopFame = view.frame
        view.frame.origin.y -= 3*(TopFame.size.height)
        UIView.animateWithDuration(0.8, delay: 2.0, options: .CurveEaseOut, animations: {
            var basketTopFrame = view.frame
            basketTopFrame.origin.y += 3*(basketTopFrame.size.height)
            
            view.frame = basketTopFrame
            
            }, completion: { finished in
                print("arriveLent")
        })
    }
    
    func arriveVite(view: UIView){
        view.hidden = false
        view.alpha = 1.0
        let TopFame = view.frame
        view.frame.origin.y -= 2*(TopFame.size.height)
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: {
            var basketTopFrame = view.frame
            basketTopFrame.origin.y += 2*(basketTopFrame.size.height)
            
            view.frame = basketTopFrame
            
            }, completion: { finished in
                print("arriveVite")
        })
    }
    
    func arriveViteBas(view: UIView){
        view.hidden = false
        view.alpha = 1.0
        let TopFame = view.frame
        view.frame.origin.y += 2*(TopFame.size.height)
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: {
            var basketTopFrame = view.frame
            basketTopFrame.origin.y -= 2*(basketTopFrame.size.height)
            
            view.frame = basketTopFrame
            
            }, completion: { finished in
                print("arrivedenbas")
        })
    }
    
    func arriveFinJeu(view: UIView){
        view.hidden = false
        view.alpha = 1.0
        let TopFame = view.frame
        view.frame.origin.y -= 2*(TopFame.size.height)
        UIView.animateWithDuration(0.7, delay: 0.0, options: .CurveEaseOut, animations: {
            var basketTopFrame = view.frame
            basketTopFrame.origin.y += 2*(basketTopFrame.size.height)
            view.frame = basketTopFrame
            }, completion: { finished in
                print("arriveFinJeu")
        })
    }
    
    func arriveLoin(view: UIView){
        view.hidden = false
        view.alpha = 1.0
        let TopFame = view.frame
        view.frame.origin.y -= 16*(TopFame.size.height)
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: {
            var basketTopFrame = view.frame
            basketTopFrame.origin.y += 16*(basketTopFrame.size.height)
            
            view.frame = basketTopFrame
            
            }, completion: { finished in
                print("arriveVite")
        })
    }
    
    func animBooster(view: UIView){
        view.alpha = 1.0
        UIView.animateWithDuration(0.4, delay: 0.1, options: .CurveEaseOut, animations: {
            view.alpha = 0.9
            }, completion: { finished in
                self.swiftris.animateBooster()
        })
    }
    
    func boosterDidAnimate(swiftris: Swiftris) {

    }

    
    func gameDidBegin(swiftris: Swiftris) {
        
        if boosterMode == true {
            view.userInteractionEnabled = false
            animBooster(boutonBooster)
        } else {
            view.userInteractionEnabled = true
        }
        
        tempsBoost = 0
        tempsMis = 0
        
        levelLabel.text = "\(swiftris.level)"
        scoreLabel.text = "\(swiftris.score)"
        cityLabel.text = "\(swiftris.city)"
        viesLabel.text = "\(swiftris.vies)"
        
        
        cadreJeu.hidden = false
        cadreJoujou.hidden = false
        
        barreBas.hidden = false
        
        var lotLot1: Int = 2
        var lotLot2: Int = 2
        var lotLot3: Int = 2
        
        var lotNiveau: String
        
        let kreste = (swiftris.level)%3
        let kreste2 = ((swiftris.level)-1)%3
        let kepizode = ((swiftris.level)-1-kreste2)/3
        
        let caDepend:Int = Int(arc4random_uniform(7))
        let caDepend2:Int = Int(arc4random_uniform(2))
        let caDepend3:Int = Int(arc4random_uniform(3))

        if kepizode == 31 {
            switch caDepend {
            case 0:
                lotEpisode = "laby"
            case 1:
                lotEpisode = "echec"
            case 2:
                lotEpisode = "maya"
            case 3:
                lotEpisode = "art"
            case 4:
                lotEpisode = "ny"
            case 5:
                lotEpisode = "arab"
            case 6:
                lotEpisode = "mandala"
            default:
                lotEpisode = "minenew"}
        }
        
        if (kepizode == 35 || kepizode ==  40 || kepizode ==  45 || kepizode ==  50 || kepizode ==  55 || kepizode ==  60 || kepizode ==  65 || kepizode ==  70 || kepizode ==  75 || kepizode ==  80) {
            let caDepend4:Int = Int(arc4random_uniform(31))
            switch caDepend4 {
            case 0:
                lotEpisode = "ecolenew"
            case 1:
                lotEpisode = "cookienew"
            case 2:
                lotEpisode = "foretnew"
            case 3:
                lotEpisode = "fermenew"
            case 4:
                lotEpisode = "sportnew"
            case 5:
                lotEpisode = "tournoinew"
            case 6:
                lotEpisode = "minenew"
            case 7:
                lotEpisode = "chatonew"
            case 8:
                lotEpisode = "letnew"
            case 9:
                lotEpisode = "jeu"
            case 10:
                lotEpisode = "shop"
            case 11:
                lotEpisode = "champion"
            case 12:
                lotEpisode = "oiseau"
            case 13:
                lotEpisode = "mer"
            case 14:
                lotEpisode = "merde"
            case 15:
                lotEpisode = "merde"
            case 16:
                lotEpisode = "glace"
            case 17:
                lotEpisode = "mandala"
            case 18:
                lotEpisode = "glace"
            case 19:
                lotEpisode = "mossi"
            case 20:
                lotEpisode = "doge"
            case 21:
                lotEpisode = "aus"
            case 22:
                lotEpisode = "shan"
            case 23:
                lotEpisode = "drap"
            case 24:
                lotEpisode = "gw"
            case 25:
                lotEpisode = "champion"
            case 26:
                lotEpisode = "jv"
            case 27:
                lotEpisode = "mossi"
            case 28:
                lotEpisode = "jeu"
            case 29:
                lotEpisode = "jv"
            case 30:
                lotEpisode = "letnew"
            default:
                lotEpisode = "minenew"
            }
        }
        
        if (kepizode > 85 && kepizode < 96) {
            let caDepend5:Int = Int(arc4random_uniform(31))
            switch caDepend5 {
            case 0:
                lotEpisode = "gr"
            case 1:
                lotEpisode = "gs"
            case 2:
                lotEpisode = "gt"
            case 3:
                lotEpisode = "gu"
            case 4:
                lotEpisode = "gv"
            case 5:
                lotEpisode = "gw"
            case 6:
                lotEpisode = "gx"
            case 7:
                lotEpisode = "gy"
            case 8:
                lotEpisode = "gz"
            case 9:
                lotEpisode = "gd"
            case 10:
                lotEpisode = "ge"
            case 11:
                lotEpisode = "gf"
            case 12:
                lotEpisode = "gg"
            case 13:
                lotEpisode = "gh"
            case 14:
                lotEpisode = "gi"
            case 15:
                lotEpisode = "gj"
            case 16:
                lotEpisode = "gk"
            case 17:
                lotEpisode = "gl"
            case 18:
                lotEpisode = "gm"
            case 19:
                lotEpisode = "gn"
            case 20:
                lotEpisode = "go"
            case 21:
                lotEpisode = "aus"
            case 22:
                lotEpisode = "shan"
            case 23:
                lotEpisode = "drap"
            case 24:
                lotEpisode = "gw"
            case 25:
                lotEpisode = "champion"
            case 26:
                lotEpisode = "jv"
            case 27:
                lotEpisode = "mossi"
            case 28:
                lotEpisode = "ge"
            case 29:
                lotEpisode = "gg"
            case 30:
                lotEpisode = "gi"
            default:
                lotEpisode = "cookienew"
            }
        }
        
        switch kreste {
        case 0:
            lotNiveau = "c"
        case 1:
            lotNiveau = "a"
        case 2:
            lotNiveau = "b"
        default:
            lotNiveau = "a"
        }
        
        if (kepizode ==  31 || kepizode ==  30 || kepizode ==  29 || kepizode ==  27 || kepizode ==  25 || kepizode ==  24 || kepizode ==  16 || kepizode ==  15) && kreste == 0 && caDepend2 == 1 {
            lotNiveau = "a"
        } else if (kepizode ==  31 || kepizode ==  30 || kepizode ==  29 || kepizode ==  27 || kepizode ==  25 || kepizode ==  24 || kepizode ==  16 || kepizode ==  15) && kreste == 0 {
            lotNiveau = "b"
        }
        
        if (kepizode == 36 || kepizode ==  41 || kepizode ==  46 || kepizode ==  51 || kepizode ==  56 || kepizode ==  61 || kepizode ==  66 || kepizode ==  71 || kepizode ==  76 || kepizode ==  81) && caDepend3 == 1 {
            lotNiveau = "a"
        } else if (kepizode == 36 || kepizode ==  41 || kepizode ==  46 || kepizode ==  51 || kepizode ==  56 || kepizode ==  61 || kepizode ==  66 || kepizode ==  71 || kepizode ==  76 || kepizode ==  81) && caDepend3 == 2 {
            lotNiveau = "b"
        } else if (kepizode == 36 || kepizode ==  41 || kepizode ==  46 || kepizode ==  51 || kepizode ==  56 || kepizode ==  61 || kepizode ==  66 || kepizode ==  71 || kepizode ==  76 || kepizode ==  81) {
            lotNiveau = "c"
        }
        
        if gainCumule < 40 {
            modeJeu = 0
        } else if gainCumule > 70 {
            modeJeu = 2
        } else {
            modeJeu = 1
        }
        
        switch Int(arc4random_uniform(5)) {
        case 0:
            lotLot1 = 1
        case 1:
            lotLot1 = 2
        case 2:
            lotLot1 = 3
        case 3:
            lotLot1 = 4
        default:
            lotLot1 = 5
        }
        switch Int(arc4random_uniform(5)) {
        case 0:
            lotLot2 = 1
        case 1:
            lotLot2 = 2
        case 2:
            lotLot2 = 3
        case 3:
            lotLot2 = 4
        default:
            lotLot2 = 5
        }
        switch Int(arc4random_uniform(5)) {
        case 0:
            lotLot3 = 1
        case 1:
            lotLot3 = 2
        case 2:
            lotLot3 = 3
        case 3:
            lotLot3 = 4
        default:
            lotLot3 = 5
        }
        
        var imageA = String(lotEpisode)+String(lotNiveau)+String(lotLot1)+"a.png"
        var imageB = String(lotEpisode)+String(lotNiveau)+String(lotLot2)+"b.png"
        var imageC = String(lotEpisode)+String(lotNiveau)+String(lotLot3)+"c.png"
        
        switch Int(arc4random_uniform(6)) {
        case 0:
            imageA = String(lotEpisode)+String(lotNiveau)+String(lotLot1)+"a.png"
            imageB = String(lotEpisode)+String(lotNiveau)+String(lotLot2)+"b.png"
            imageC = String(lotEpisode)+String(lotNiveau)+String(lotLot3)+"c.png"
        case 1:
            imageA = String(lotEpisode)+String(lotNiveau)+String(lotLot1)+"a.png"
            imageB = String(lotEpisode)+String(lotNiveau)+String(lotLot3)+"c.png"
            imageC = String(lotEpisode)+String(lotNiveau)+String(lotLot2)+"b.png"
        case 2:
            imageA = String(lotEpisode)+String(lotNiveau)+String(lotLot2)+"b.png"
            imageB = String(lotEpisode)+String(lotNiveau)+String(lotLot1)+"a.png"
            imageC = String(lotEpisode)+String(lotNiveau)+String(lotLot3)+"c.png"
        case 3:
            imageA = String(lotEpisode)+String(lotNiveau)+String(lotLot2)+"b.png"
            imageB = String(lotEpisode)+String(lotNiveau)+String(lotLot3)+"c.png"
            imageC = String(lotEpisode)+String(lotNiveau)+String(lotLot1)+"a.png"
        case 4:
            imageA = String(lotEpisode)+String(lotNiveau)+String(lotLot3)+"c.png"
            imageB = String(lotEpisode)+String(lotNiveau)+String(lotLot1)+"a.png"
            imageC = String(lotEpisode)+String(lotNiveau)+String(lotLot2)+"b.png"
        default:
            imageA = String(lotEpisode)+String(lotNiveau)+String(lotLot3)+"c.png"
            imageB = String(lotEpisode)+String(lotNiveau)+String(lotLot2)+"b.png"
            imageC = String(lotEpisode)+String(lotNiveau)+String(lotLot1)+"a.png"
        }
        
        let imageGauche = UIImage(named: imageA) as UIImage?
        boutonDeGauche.setBackgroundImage(imageGauche, forState: .Normal)
        boutonDeGauche.addTarget(self, action: "boutonTouche:", forControlEvents:.TouchUpInside)
        boutonDeGauche.alpha = 1
        
        let imageMilieu = UIImage(named: imageB) as UIImage?
        boutonDuMilieu.setBackgroundImage(imageMilieu, forState: .Normal)
        boutonDuMilieu.addTarget(self, action: "boutonTouche:", forControlEvents:.TouchUpInside)
        boutonDuMilieu.alpha = 1
        
        let imageDroite = UIImage(named: imageC) as UIImage?
        boutonDeDroite.setBackgroundImage(imageDroite, forState: .Normal)
        boutonDeDroite.addTarget(self, action: "boutonTouche:", forControlEvents:.TouchUpInside)
        boutonDeDroite.alpha = 1
        
        cadreJeu.addSubview(massiHautgauche);
        cadreJeu.addSubview(massiHautdroite);
        cadreJeu.addSubview(massiBasgauche);
        cadreJeu.addSubview(massiBasdroite);


        let thierryHasard = Int(arc4random_uniform(24))
        
        let imgpointillesv = UIImage(named: "pointilles.png") as UIImage?
        let imgpointillesh = UIImage(named: "pointillesh.png") as UIImage?
        
        switch modeJeu {
        case 0:
            pointiH1.hidden = true
            pointiH2.hidden = true
            pointiH3.hidden = true
            pointiV1.hidden = false
            pointiV2.hidden = false
            pointiV3.hidden = false
            cadreJeu.addSubview(grosPointillesv);
            grosPointillesv.image = imgpointillesv;
            grosPointillesv.hidden = false
            grosPointillesh.hidden = true
            if thierryHasard < 6 {
                massiHautgauche.contentMode = UIViewContentMode.TopLeft
                massiHautdroite.contentMode = UIViewContentMode.TopRight
                massiBasgauche.contentMode = UIViewContentMode.BottomLeft
                massiBasdroite.contentMode = UIViewContentMode.BottomRight
            } else {
                massiHautgauche.contentMode = UIViewContentMode.TopRight
                massiHautdroite.contentMode = UIViewContentMode.TopLeft
                massiBasgauche.contentMode = UIViewContentMode.BottomRight
                massiBasdroite.contentMode = UIViewContentMode.BottomLeft
            }
        case 1:
            pointiH1.hidden = false
            pointiH2.hidden = false
            pointiH3.hidden = false
            pointiV1.hidden = true
            pointiV2.hidden = true
            pointiV3.hidden = true
            cadreJeu.addSubview(grosPointillesh);
            grosPointillesh.image = imgpointillesh;
            grosPointillesv.hidden = true
            grosPointillesh.hidden = false
            if thierryHasard < 6 {
                massiHautgauche.contentMode = UIViewContentMode.TopLeft
                massiHautdroite.contentMode = UIViewContentMode.TopRight
                massiBasgauche.contentMode = UIViewContentMode.BottomLeft
                massiBasdroite.contentMode = UIViewContentMode.BottomRight
            } else {
                massiHautgauche.contentMode = UIViewContentMode.BottomLeft
                massiHautdroite.contentMode = UIViewContentMode.BottomRight
                massiBasgauche.contentMode = UIViewContentMode.TopLeft
                massiBasdroite.contentMode = UIViewContentMode.TopRight
            }
        case 2:
            pointiH1.hidden = false
            pointiH2.hidden = false
            pointiH3.hidden = false
            pointiV1.hidden = false
            pointiV2.hidden = false
            pointiV3.hidden = false
            cadreJeu.addSubview(grosPointillesh);
            grosPointillesh.image = imgpointillesh;
            cadreJeu.addSubview(grosPointillesv);
            grosPointillesv.image = imgpointillesv;
            grosPointillesv.hidden = false
            grosPointillesh.hidden = false
            if thierryHasard == 1 {
                massiHautgauche.contentMode = UIViewContentMode.TopLeft
                massiHautdroite.contentMode = UIViewContentMode.TopRight
                massiBasgauche.contentMode = UIViewContentMode.BottomLeft
                massiBasdroite.contentMode = UIViewContentMode.BottomRight
            } else if thierryHasard == 2 {
                massiHautgauche.contentMode = UIViewContentMode.TopLeft
                massiHautdroite.contentMode = UIViewContentMode.TopRight
                massiBasgauche.contentMode = UIViewContentMode.BottomRight
                massiBasdroite.contentMode = UIViewContentMode.BottomLeft
            } else if thierryHasard == 3 {
                massiHautgauche.contentMode = UIViewContentMode.TopLeft
                massiHautdroite.contentMode = UIViewContentMode.BottomRight
                massiBasgauche.contentMode = UIViewContentMode.TopRight
                massiBasdroite.contentMode = UIViewContentMode.BottomLeft
            } else if thierryHasard == 4 {
                massiHautgauche.contentMode = UIViewContentMode.TopLeft
                massiHautdroite.contentMode = UIViewContentMode.BottomRight
                massiBasgauche.contentMode = UIViewContentMode.BottomLeft
                massiBasdroite.contentMode = UIViewContentMode.TopRight
            } else if thierryHasard == 5 {
                massiHautgauche.contentMode = UIViewContentMode.TopLeft
                massiHautdroite.contentMode = UIViewContentMode.BottomLeft
                massiBasgauche.contentMode = UIViewContentMode.TopRight
                massiBasdroite.contentMode = UIViewContentMode.BottomRight
            } else if thierryHasard == 6 {
                massiHautgauche.contentMode = UIViewContentMode.TopLeft
                massiHautdroite.contentMode = UIViewContentMode.BottomLeft
                massiBasgauche.contentMode = UIViewContentMode.BottomRight
                massiBasdroite.contentMode = UIViewContentMode.TopRight
            } else if thierryHasard == 7 {
                massiHautgauche.contentMode = UIViewContentMode.TopRight
                massiHautdroite.contentMode = UIViewContentMode.TopLeft
                massiBasgauche.contentMode = UIViewContentMode.BottomRight
                massiBasdroite.contentMode = UIViewContentMode.BottomLeft
            } else if thierryHasard == 8 {
                massiHautgauche.contentMode = UIViewContentMode.TopRight
                massiHautdroite.contentMode = UIViewContentMode.TopLeft
                massiBasgauche.contentMode = UIViewContentMode.BottomLeft
                massiBasdroite.contentMode = UIViewContentMode.BottomRight
            } else if thierryHasard == 9 {
                massiHautgauche.contentMode = UIViewContentMode.TopRight
                massiHautdroite.contentMode = UIViewContentMode.BottomRight
                massiBasgauche.contentMode = UIViewContentMode.TopLeft
                massiBasdroite.contentMode = UIViewContentMode.BottomLeft
            } else if thierryHasard == 10 {
                massiHautgauche.contentMode = UIViewContentMode.TopRight
                massiHautdroite.contentMode = UIViewContentMode.BottomRight
                massiBasgauche.contentMode = UIViewContentMode.BottomLeft
                massiBasdroite.contentMode = UIViewContentMode.TopLeft
            } else if thierryHasard == 11 {
                massiHautgauche.contentMode = UIViewContentMode.TopRight
                massiHautdroite.contentMode = UIViewContentMode.BottomLeft
                massiBasgauche.contentMode = UIViewContentMode.BottomRight
                massiBasdroite.contentMode = UIViewContentMode.TopLeft
            } else if thierryHasard == 12 {
                massiHautgauche.contentMode = UIViewContentMode.TopRight
                massiHautdroite.contentMode = UIViewContentMode.BottomLeft
                massiBasgauche.contentMode = UIViewContentMode.TopLeft
                massiBasdroite.contentMode = UIViewContentMode.BottomRight
            } else if thierryHasard == 13 {
                massiHautgauche.contentMode = UIViewContentMode.BottomLeft
                massiHautdroite.contentMode = UIViewContentMode.TopLeft
                massiBasgauche.contentMode = UIViewContentMode.TopRight
                massiBasdroite.contentMode = UIViewContentMode.BottomRight
            } else if thierryHasard == 14 {
                massiHautgauche.contentMode = UIViewContentMode.BottomLeft
                massiHautdroite.contentMode = UIViewContentMode.TopLeft
                massiBasgauche.contentMode = UIViewContentMode.BottomRight
                massiBasdroite.contentMode = UIViewContentMode.TopRight
            } else if thierryHasard == 15 {
                massiHautgauche.contentMode = UIViewContentMode.BottomLeft
                massiHautdroite.contentMode = UIViewContentMode.TopRight
                massiBasgauche.contentMode = UIViewContentMode.BottomRight
                massiBasdroite.contentMode = UIViewContentMode.TopLeft
            } else if thierryHasard == 16 {
                massiHautgauche.contentMode = UIViewContentMode.BottomLeft
                massiHautdroite.contentMode = UIViewContentMode.TopRight
                massiBasgauche.contentMode = UIViewContentMode.TopLeft
                massiBasdroite.contentMode = UIViewContentMode.BottomRight
            } else if thierryHasard == 17 {
                massiHautgauche.contentMode = UIViewContentMode.BottomLeft
                massiHautdroite.contentMode = UIViewContentMode.BottomRight
                massiBasgauche.contentMode = UIViewContentMode.TopLeft
                massiBasdroite.contentMode = UIViewContentMode.TopRight
            } else if thierryHasard == 18 {
                massiHautgauche.contentMode = UIViewContentMode.BottomLeft
                massiHautdroite.contentMode = UIViewContentMode.BottomRight
                massiBasgauche.contentMode = UIViewContentMode.TopRight
                massiBasdroite.contentMode = UIViewContentMode.TopLeft
            } else if thierryHasard == 19 {
                massiHautgauche.contentMode = UIViewContentMode.BottomRight
                massiHautdroite.contentMode = UIViewContentMode.TopLeft
                massiBasgauche.contentMode = UIViewContentMode.TopRight
                massiBasdroite.contentMode = UIViewContentMode.BottomLeft
            } else if thierryHasard == 20 {
                massiHautgauche.contentMode = UIViewContentMode.BottomRight
                massiHautdroite.contentMode = UIViewContentMode.TopLeft
                massiBasgauche.contentMode = UIViewContentMode.BottomLeft
                massiBasdroite.contentMode = UIViewContentMode.TopRight
            } else if thierryHasard == 21 {
                massiHautgauche.contentMode = UIViewContentMode.BottomRight
                massiHautdroite.contentMode = UIViewContentMode.TopRight
                massiBasgauche.contentMode = UIViewContentMode.BottomLeft
                massiBasdroite.contentMode = UIViewContentMode.TopLeft
            } else if thierryHasard == 22 {
                massiHautgauche.contentMode = UIViewContentMode.BottomRight
                massiHautdroite.contentMode = UIViewContentMode.TopRight
                massiBasgauche.contentMode = UIViewContentMode.TopLeft
                massiBasdroite.contentMode = UIViewContentMode.BottomLeft
            } else if thierryHasard == 23 {
                massiHautgauche.contentMode = UIViewContentMode.BottomRight
                massiHautdroite.contentMode = UIViewContentMode.BottomLeft
                massiBasgauche.contentMode = UIViewContentMode.TopLeft
                massiBasdroite.contentMode = UIViewContentMode.TopRight
            } else if thierryHasard == 24 {
                massiHautgauche.contentMode = UIViewContentMode.BottomRight
                massiHautdroite.contentMode = UIViewContentMode.BottomLeft
                massiBasgauche.contentMode = UIViewContentMode.TopRight
                massiBasdroite.contentMode = UIViewContentMode.TopLeft
            } else {
                massiHautgauche.contentMode = UIViewContentMode.BottomRight
                massiHautdroite.contentMode = UIViewContentMode.BottomLeft
                massiBasgauche.contentMode = UIViewContentMode.TopRight
                massiBasdroite.contentMode = UIViewContentMode.TopLeft
            }
        default:
            massiHautgauche.contentMode = UIViewContentMode.TopRight
            massiHautdroite.contentMode = UIViewContentMode.TopLeft
            massiBasgauche.contentMode = UIViewContentMode.BottomRight
            massiBasdroite.contentMode = UIViewContentMode.BottomLeft
        }
        
        massiHautgauche.contentMode = UIViewContentMode.Redraw
        massiHautdroite.contentMode = UIViewContentMode.Redraw
        massiBasgauche.contentMode = UIViewContentMode.Redraw
        massiBasdroite.contentMode = UIViewContentMode.Redraw
        
        massiHautgauche.clipsToBounds = true
        massiHautdroite.clipsToBounds = true
        massiBasgauche.clipsToBounds = true
        massiBasdroite.clipsToBounds = true

        
        switch Int(arc4random_uniform(3)) {
        case 0:
            massiHautgauche.image = imageGauche;
            massiHautdroite.image = imageGauche;
            massiBasgauche.image = imageGauche;
            massiBasdroite.image = imageGauche;
            choixFait = "gauche"
        case 1:
            massiHautgauche.image = imageMilieu;
            massiHautdroite.image = imageMilieu;
            massiBasgauche.image = imageMilieu;
            massiBasdroite.image = imageMilieu;
            choixFait = "milieu"
        default:
            massiHautgauche.image = imageDroite;
            massiHautdroite.image = imageDroite;
            massiBasgauche.image = imageDroite;
            massiBasdroite.image = imageDroite;
            choixFait = "droite"
        }
        
        
    }
    
    func caJoue() {
        
        scene.tickLengthMillis = TickLengthLevelOne
        // The following is false when restarting a new game
        if swiftris.nextShape != nil && swiftris.nextShape!.blocks[0].sprite == nil {
            scene.addPreviewShapeToScene(swiftris.nextShape!) {
                self.nextShape()
            }
        } else {
            nextShape()
        }
        
    }
    
    func boutonTouche(sender:UIButton!)
    {
        let arrondi:Int = Int(gainCumule/10)
        var letal = "taler"+String(arrondi)
        var letaler = taler1
        tempsPartie += tempsMis
        switch arrondi {
        case 0:
            letaler = taler1
        case 1:
            letaler = taler2
        case 2:
            letaler = taler3
        case 3:
            letaler = taler4
        case 4:
            letaler = taler5
        case 5:
            letaler = taler6
        case 6:
            letaler = taler7
        case 7:
            letaler = taler8
        case 8:
            letaler = taler9
        case 9:
            letaler = taler10
        default:
            letaler = taler10
        }
        gainLabel.textColor = UIColor.yellowColor()
        if (sender.frame == CGRectMake(6, 275, 90, 90) && choixFait == "gauche") || (sender.frame == CGRectMake(115, 275, 90, 90) && choixFait == "milieu") || (sender.frame == CGRectMake(224, 275, 90, 90) && choixFait == "droite") {
            perfectLabel.text = " "
            if tempsMis == 0 {
                gainArgent = 6
                perfectLabel.text = "PERFECT!"
                perfectLabel.textColor = UIColor.whiteColor()
                disparaitVite(perfectLabel)
                disparaitVite(cadreStars)
            } else if tempsMis == 1 {
                gainArgent = 6
                perfectLabel.text = "PERFECT!"
                perfectLabel.textColor = UIColor.whiteColor()
                disparaitVite(perfectLabel)
                disparaitVite(cadreStars)
            } else if tempsMis == 2 {
                gainArgent = 5
                perfectLabel.text = "NICE!"
                perfectLabel.textColor = UIColor.yellowColor()
                disparaitVite(perfectLabel)
                disparaitVite(cadreStars)
            } else if tempsMis == 3 {
                gainArgent = 4
                perfectLabel.text = "NICE!"
                perfectLabel.textColor = UIColor.yellowColor()
                disparaitVite(perfectLabel)
            } else {
                gainArgent = 3
            }
            gainLabel.text = "+"+String(gainArgent)
            if modePoints == 2 && compteur > 28 {
                view.userInteractionEnabled = false
                swiftris.winGame()
            } else {
                swiftris.beginGame()
            }
            if isPlaying == true {
                scene.playSound("forwin.mp3")
            }
            if (modePoints != 2 && modePoints != 4) && letaler.hidden == true {
                arriveLoin(letaler)
            }
            tempsBoost = 0
        } else {
            disparaitVite(fondRouge)
            if gainCumule > 3 {
                gainArgent = -3
            }
            gainLabel.text = "-3"
            gainLabel.textColor = UIColor.redColor()
            tempsBoost = 0
            jaugeBoost = 0
            if isPlaying == true {
                scene.playSound("lajaiperdu.mp3")
            }
            if modePoints == 2 {
                view.userInteractionEnabled = false
                compteur -= 1
                swiftris.endGame()
            } else {
                swiftris.beginGame()
            }
        }
        
        gainCumule += gainArgent
        if gainCumule < 0 {
            gainCumule = 0
        }
        tempsLabel.text = String(gainCumule)
        
        if modePoints == 3 {
            barreBoost.hidden = false
        } else if modePoints == 4 {
            barreBoost.hidden = false
        } else {
            compteur += 1
            compteurLabel.text = String(30-compteur)
            barreBoost.frame.size.height = CGFloat(150-(compteur*5))
            barreBoost.frame.origin.y = 45+CGFloat(compteur*5)
            if compteur > 30 {
                barreBoost.frame.size.height = 150
                barreBoost.frame.origin.y = 45
            }
        }
        if modePoints == 0 || modePoints == 1 {
            if gainCumule > 99 {
                view.userInteractionEnabled = false
                swiftris.winGame()
            } else if compteur > 29 && gainCumule <= 99 {
                view.userInteractionEnabled = false
                swiftris.endGame()
            } else {
                caJoue()
            }
            boutonVole1(gainLabel)
            disparaitVite(gainLabel)
        } else if modePoints == 2 {
            if compteur > 28 {
                compteurLabel.text = String(30-compteur)
            } else {
                caJoue()
            }
        } else if modePoints == 3 && cadreNoirJeu.hidden == true {
            if gainCumule > 99 {
                view.userInteractionEnabled = false
                swiftris.winGame()
            } else {
                caJoue()
            }
            boutonVole1(gainLabel)
            disparaitVite(gainLabel)
        } else if modePoints == 4 && cadreNoirJeu.hidden == true {
            barreBoost2.frame.size.height = CGFloat(gainCumule*15/10)
            barreBoost2.frame.origin.y = 195-CGFloat(gainCumule*15/10)
            if gainCumule > 99 {
                view.userInteractionEnabled = false
                swiftris.winGame()
            } else {
                caJoue()
            }
            if gainCumule >= 0 {
                barreBoost2.hidden = false
            }
        }
        
    }
    
    func setDidWin(swiftris: Swiftris) {
        
    }
    
    func gameDidWin(swiftris: Swiftris) {
        view.userInteractionEnabled = true
        scene.stopTicking()
        if isPlaying == true {
            scene.playSound("songagne.mp3")
        }
        
        if isPlaying == true {
            audioJeu.stop()
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        }
        
        let sablier01 = UIImage(named: "sablier1.png") as UIImage?
        let sablier02 = UIImage(named: "sablier2.png") as UIImage?
        let sablier03 = UIImage(named: "sablier3.png") as UIImage?
        let sablier04 = UIImage(named: "sablier4.png") as UIImage?
        let sablier05 = UIImage(named: "sablier5.png") as UIImage?
        
        cadreWinPost.hidden = true
        let vraiTemps:Int = Int(tempsPartie/2)
        sablierLabel.text = String(vraiTemps)+"s."
        let argentCagnotte:Int = Int(2015/tempsPartie)
        cagnotteLabel.text = String(argentCagnotte)
        
        if tempsPartie < 30 {
            sablierImage.image = sablier01
        } else if tempsPartie >= 30 && tempsPartie < 45 {
            sablierImage.image = sablier02
        } else if tempsPartie >= 45 && tempsPartie < 60 {
            sablierImage.image = sablier03
        } else if tempsPartie >= 60 && tempsPartie < 70 {
            sablierImage.image = sablier04
        } else {
            sablierImage.image = sablier05
        }
        
        cadreNoirJeu.hidden = false
        cadreJoujou.hidden = true
        cadreJeu.hidden = true
        barreBas.hidden = true
        
        boutonCadeauTombe.hidden = false

        arriveFinJeu(cadreWin)
        boutonGrossit(boutonCadeauTombe)
        
        tempsLabel.text = "0"
        compteurLabel.text = "30"
        
        let imgduRefill = UIImage(named: "kadorefill.png") as UIImage?
        let imgduMagicEye = UIImage(named: "kadomagiceye.png") as UIImage?
        let imgduJoker = UIImage(named: "kadojoker.png") as UIImage?
        switch Int(arc4random_uniform(8)) {
        case 0:
            gainkado1Image.image = imgduJoker
            if swiftris.cadeau1 < 9 {
                gainKado = 1
            } else {
                gainKado = 0
            }
            swiftris.cadeau1 += gainKado
        case 1:
            gainkado1Image.image = imgduRefill
            if swiftris.cadeau3 < 6 {
                gainKado = 3
            } else if swiftris.cadeau3 == 6 {
                gainKado = 2
            } else if swiftris.cadeau3 == 7 {
                gainKado = 1
            } else if swiftris.cadeau3 == 8 {
                gainKado = 1
            } else {
                gainKado = 0
            }
            swiftris.cadeau3 += gainKado
        case 3:
            gainkado1Image.image = imgduMagicEye
            if swiftris.cadeau2 < 9 {
                gainKado = 1
            } else {
                gainKado = 0
            }
            swiftris.cadeau2 += gainKado
        default:
            gainkado1Image.image = imgduJoker
            if swiftris.cadeau1 < 8 {
                gainKado = 2
            } else {
                gainKado = 0
            }
            swiftris.cadeau1 += gainKado
        }
        
        gainkado1Label.text = "+"+String(gainKado)
        cadeau1Label.text = "\(swiftris.cadeau1)"
        cadeau2Label.text = "\(swiftris.cadeau3)"
        cadeau3Label.text = "\(swiftris.cadeau2)"
        let sauvegrad = NSUserDefaults.standardUserDefaults()
        sauvegrad.setInteger(swiftris.cadeau1, forKey: "jokerBanque")
        sauvegrad.setInteger(swiftris.cadeau2, forKey: "magiceyeBanque")
        sauvegrad.setInteger(swiftris.cadeau3, forKey: "refillBanque")
        
        compteur = 0
        tempsBoost = 0
        jaugeBoost = 0

    }
    
    func gameFoutu(sender:UIButton!){
        view.userInteractionEnabled = true
        if isPlaying == true {
            scene.playSound("pourlelose.mp3")
        }
        
        tempsLabel.text = "0"
        compteurLabel.text = "30"
        tempsPartie = 0
        
        cadreNoirJeu.hidden = false
        arriveVite(cadreLose)
        cadrePresque.hidden = true
        cadreJeu.hidden = true
        cadreJoujou.hidden = true
        grosPointillesv.hidden = true
        grosPointillesh.hidden = true
        barreBas.hidden = true
        taler1.hidden = true
        taler2.hidden = true
        taler3.hidden = true
        taler4.hidden = true
        taler5.hidden = true
        taler6.hidden = true
        taler7.hidden = true
        taler8.hidden = true
        taler9.hidden = true
        taler10.hidden = true
        
        compteur = 0
        tempsMis = 0
        tempsBoost = 0
        jaugeBoost = 0
        
        swiftris.vies -= 1
        let sauvevie = NSUserDefaults.standardUserDefaults()
        sauvevie.setInteger(swiftris.vies, forKey: "viesBanque")
        nombreDefaites += 1
        sauvevie.setInteger(nombreDefaites, forKey: "defaitesBanque")
        viesLabel.text = "\(swiftris.vies)"
        gainCumule = 0
        
        if swiftris.vies <= 0 {
            swiftris.vies = 0
            dateDefaite = CFAbsoluteTimeGetCurrent()
            sauvevie.setDouble(dateDefaite!, forKey: "dateBanque")
        }

    }
    
    
    func gameDidEnd(swiftris: Swiftris) {
        view.userInteractionEnabled = true
        scene.stopTicking()
        
        cadreNoirJeu.hidden = false
        
        if modePoints == 4 {
            view.userInteractionEnabled = true
            if isPlaying == true {
                scene.playSound("pourlelose.mp3")
            }
            
            tempsLabel.text = "0"
            compteurLabel.text = "30"
            tempsPartie = 0
            
            cadreNoirJeu.hidden = false
            cadrePresque.hidden = true
            cadreJeu.hidden = true
            cadreJoujou.hidden = true
            arriveFinJeu(cadreLose)
            grosPointillesv.hidden = true
            grosPointillesh.hidden = true
            barreBas.hidden = true
            taler1.hidden = true
            taler2.hidden = true
            taler3.hidden = true
            taler4.hidden = true
            taler5.hidden = true
            taler6.hidden = true
            taler7.hidden = true
            taler8.hidden = true
            taler9.hidden = true
            taler10.hidden = true
            
            compteur = 0
            tempsMis = 0
            tempsBoost = 0
            jaugeBoost = 0
            
            swiftris.vies -= 1
            let sauvevie = NSUserDefaults.standardUserDefaults()
            sauvevie.setInteger(swiftris.vies, forKey: "viesBanque")
            nombreDefaites += 1
            sauvevie.setInteger(nombreDefaites, forKey: "defaitesBanque")
            viesLabel.text = "\(swiftris.vies)"
            gainCumule = 0
            
            if swiftris.vies <= 0 {
                swiftris.vies = 0
                dateDefaite = CFAbsoluteTimeGetCurrent()
                sauvevie.setDouble(dateDefaite!, forKey: "dateBanque")
            }
            
        } else if modePoints == 2 {
            presqueLabel.text = NSLocalizedString("YOU_ONLY",comment:"You have only ")+String(29-compteur)+NSLocalizedString("LEFT_SOLVE",comment:" Massicots left to solve...")
            arriveFinJeu(cadrePresque)
        } else {
            presqueLabel.text = NSLocalizedString("YOU_ONLY",comment:"You have only ")+String(100-gainCumule)+NSLocalizedString("COINS_GET",comment:" coins left to get!")
            arriveFinJeu(cadrePresque)
        }

    }
    
    func gameDidWait(swiftris: Swiftris) {
        
        let samdonc = NSUserDefaults.standardUserDefaults()
        maisonChoisie = samdonc.integerForKey("maisonBanque")
        voitureChoisie = samdonc.integerForKey("voitureBanque")
        piscineChoisie = samdonc.integerForKey("piscineBanque")
        var influMaison:Double = 0
        var influVoiture:Double = 0
        var influPiscine:Double = 0

        switch maisonChoisie {
        case 0:
            influMaison = 0
        case 1:
            influMaison = 5
        case 2:
            influMaison = 10
        default:
            influMaison = 0
        }
        switch voitureChoisie {
        case 0:
            influVoiture = 0
        case 1:
            influVoiture = 5
        case 2:
            influVoiture = 8
        case 3:
            influVoiture = 15
        default:
            influVoiture = 0
        }
        switch piscineChoisie {
        case 0:
            influPiscine = 0
        case 1:
            influPiscine = 5
        default:
            influPiscine = 0
        }
        
        influTotale = influMaison+influPiscine+influVoiture
        
        dateDefaite = 19830
        let soovegarde = NSUserDefaults.standardUserDefaults()
        if let lastDefaite:Double = soovegarde.doubleForKey("dateBanque") {
            dateDefaite = soovegarde.doubleForKey("dateBanque")
        }
        let tempskiPasse = CFAbsoluteTimeGetCurrent() - dateDefaite!
        let tempsinMinutes:Double = 50-influTotale-(tempskiPasse/60)
        let tempsKonverti:Int = Int(tempsinMinutes)
        if tempsinMinutes < 60 && tempsinMinutes > 0 {
            attenteLabel.text = NSLocalizedString("WAIT_A",comment:"Wait ")+String(tempsKonverti)+NSLocalizedString("WAIT_B",comment:" minutes")
        }
        scene.startTicking()
        
        arriveVite(cadreWait)
        
    }
    
    func gameDidLevelUp(swiftris: Swiftris) {
        levelLabel.text = "\(swiftris.level)"
        scene.playSound("levelup.mp3")
    }
    
    func gameShapeDidDrop(swiftris: Swiftris) {
        scene.stopTicking()
        scene.redrawShape(swiftris.fallingShape!) {
            swiftris.letShapeFall()
        }
        scene.playSound("drop.mp3")
    }
    
    func gameShapeDidLand(swiftris: Swiftris) {
        scene.stopTicking()
        self.view.userInteractionEnabled = false
        // #1
        let removedLines = swiftris.removeCompletedLines()
        if removedLines.linesRemoved.count > 0 {
            self.scoreLabel.text = "\(swiftris.score)"
            scene.animateCollapsingLines(removedLines.linesRemoved, fallenBlocks:removedLines.fallenBlocks) {
                // #2
                self.gameShapeDidLand(swiftris)
            }
            scene.playSound("bomb.mp3")
        } else {
            nextShape()
        }
    }
    
    // #3
    func gameShapeDidMove(swiftris: Swiftris) {

        tempsMis += 1
        tempsBoost += 1
        
        let tempsPasse = CFAbsoluteTimeGetCurrent() - dateDefaite!
        let tempsEnMinutes:Double = 50-influTotale-(tempsPasse/60)
        let tempsConverti:Int = Int(tempsEnMinutes)
        
        if tempsEnMinutes < 60 && tempsEnMinutes > 0 {
            attenteLabel.text = NSLocalizedString("WAIT_A",comment:"Wait ")+String(tempsConverti)+NSLocalizedString("WAIT_B",comment:" minutes")
        }
        
        if modePoints == 3 && compteur < 119 {
            compteur += 1
            let compteurFoisDeux:Int = Int((120-compteur)/2)
            compteurLabel.text = String(compteurFoisDeux)+"s"
            barreBoost.frame.size.height -= 1.25
            barreBoost.frame.origin.y += 1.25
        } else if modePoints == 3 && compteur >= 119 && cadreWin.hidden == true && cadreNoirJeu.hidden == true && swiftris.vies > 0 {
            view.userInteractionEnabled = false
            scene.stopTicking()
            swiftris.endGame()
        }
        
        if modePoints == 4 && barreBoost.frame.size.height < 149 {
            switch Int(arc4random_uniform(4)) {
            case 0:
                barreBoost.frame.size.height += 0
            case 1:
                barreBoost.frame.size.height += 5
                barreBoost.frame.origin.y -= 5
            default:
                barreBoost.frame.size.height += 0
            }
        } else if modePoints == 4 && barreBoost.frame.size.height >= 149 && cadreWin.hidden == true && cadreNoirJeu.hidden == true && swiftris.vies > 0 {
            view.userInteractionEnabled = false
            scene.stopTicking()
            swiftris.endGame()
        }

        if tempsConverti < 1 && cadreWait.hidden == false {
            
            swiftris.introGame()
            degageMenu1(cadreWait)
            scoreLabel.text = "\(swiftris.score)"
            
            cadreWait.hidden = true
            leMonde.hidden = false
            leMonde.alpha = 1
            cadreJeu.hidden = true
            cadreJoujou.hidden = true
            cadreNoir.hidden = true
            swiftris.level = 1
            swiftris.vies = 5
            compteur = 0
            gainCumule = 0
            tempsPartie = 0
            barreBas.hidden = true
            cadreNoirJeu.hidden = true
            viesLabel.text = "\(swiftris.vies)"
            let sautevie = NSUserDefaults.standardUserDefaults()
            sautevie.setInteger(swiftris.vies, forKey: "viesBanque")
            scene.stopTicking()
            if isPlaying == true {
                scene.playSound("sondejoker.mp3")
                audioJeu.stop()
                audioPlayer.prepareToPlay()
                audioPlayer.play()
            }
        }

    }
    
    

}

