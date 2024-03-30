// Bağış yöneticisi
actor ContractOwner {
  public func getOwner() : async Text {
    return "Ornek Adi";
  }
}

// Akıllı sözleşme ana mantığı
actor DonationManagement {
  // Belirlenmiş bağış alıcıları ve toplam bağış miktarı
  var donationRecipients : [Text] = ["Kizilay", "Yesilay", "Hayvanlari Koruma Dernegi"];
  var totalDonations : Nat = 0;
  var donations : [Donation] = [];

  // Bağış yapmak için fonksiyon
  public shared(msg) func makeDonation(recipient: Text, amount: Nat) : async () {
    // Belirlenmiş bağış alıcılarından biri olmalı
    assert (Array.elem(recipient, donationRecipients), "Gecersiz bagis alicisi");

    // Bağış yapılması
    totalDonations += amount;

    // Bağışı kaydet
    let donation : Donation = { donor = msg.caller; amount = amount; };
    donations := donations ++ [donation];
  }

  // Bağış alıcısı ekleme/çıkarma fonksiyonları
  public shared(msg) func addDonationRecipient(newRecipient: Text) : async () {
    donationRecipients := donationRecipients ++ [newRecipient];
  }

  public shared(msg) func removeDonationRecipient(target: Text) : async () {
    assert (Array.elem(target, donationRecipients), "Gecersiz bagıs alicisi");
    donationRecipients := [recipient | recipient in donationRecipients where (recipient != target)];
  }

  // Belirli bir bağış alıcısına yapılan bağışları almak için fonksiyon
  public query func getDonationsForRecipient(recipient: Text) : async [Donation] {
    // Belirlenmiş bağış alıcılarından biri olmalı
    assert (Array.elem(recipient, donationRecipients), "Gecersiz bagis alicisi");

    // Belirli bir alıcıya yapılan bağışları filtrele
    let filteredDonations = [donation | donation in donations where (donation.recipient == recipient)];
    return filteredDonations;
  }

  // Belirli bir bağış alıcısının toplam aldığı bağışı almak için fonksiyon
  public query func getTotalDonationsForRecipient(recipient: Text) : async Nat {
    // Belirlenmiş bağış alıcılarından biri olmalı
    assert(Array.elem(recipient, donationRecipients), "Gecersiz bagis alicisi);

    let recipientDonations = getDonationsForRecipient(recipient);
    let totalDonations = 0;
    for donation in recipientDonations {
      totalDonations += donation.amount;
    }
    return totalDonations;
  }

  // Sözleşmenin sahibi kim
  public query func getContractOwner() : async Text {
    return await ContractOwner.getOwner();
  }
}



actor TestDonationManagement {
  public shared(msg) func test() : async () {
    // Akıllı sözleşmenin çağrılması
    let donationContract = await DonationManagement();

    // Bağış yapma testi
    await donationContract.makeDonation("Kizilay", 100);
    await donationContract.makeDonation("Yesilay", 200);
    await donationContract.makeDonation("Kizilay", 150);

    // Belirli bir bağış alıcısına yapılan bağışları almak için test
    let donationsToKizilay = await donationContract.getDonationsForRecipient("Kizilay");
    assert (Array.length(donationsToKizilay) == 2, "Kizilay icin beklenen bagis sayisi yanlis");

    // Bağış alıcılarına yapılan bağışlara göre sıralama
    let let sortedRecipients = donationContract.getdonationRecipients;
    assert (Array.sort(sortedRecipients) == ["Kizilay", "Yesilay", "Hayvanlari Koruma Dernegi"], "Bagis alicilari siralamasi yanlis");

    // Yeni bir bağış alıcısı ekleme testi
    await donationContract.addDonationRecipient("Acik Kaynak Yazilim Dernegi");

    // Sıralama güncellendi mi kontrol etme
    let updatedSortedRecipients = donationContract.getDonationRecipients();
    assert (Array.elem("Acik Kaynak Yazilim Dernegi", updatedSortedRecipients), "Yeni bagis alicisi ekleme testi basarisiz");

    // Var olan bir bağış alıcısını kaldırma testi
    await donationContract.removeDonationRecipient("Yesilay");

    // Sıralama güncellendi mi kontrol etme
    let finalSortedRecipients = donationContract.getDonationRecipients();
    assert (Array.sort(finalSortedRecipients) == ["Acik Kaynak Yazilim Dernegi", "Kizilay", "Hayvanlari Koruma Dernegi"], "Var olan bagis alicisi kaldirma testi basarisiz");
  }
}
