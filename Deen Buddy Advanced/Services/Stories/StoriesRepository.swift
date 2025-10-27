//
//  StoriesRepository.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/27/25.
//

import Foundation

protocol StoriesRepositoryType {
    func allCaliphs() -> [Caliph]
    func caliph(withName name: String) -> Caliph?
}

final class StoriesRepository: StoriesRepositoryType {
    static let shared = StoriesRepository()

    private init() {}

    // MARK: - Dummy data for Abu Bakr (RA)
    // You can keep adding more StoryArticle objects here for other caliphs.

    private var abuBakrStories: [StoryArticle] {
        [
            StoryArticle(
                title: "The Cave of Thawr",
                subtitle: "A Story of Trust, Loyalty, and Allah’s Protection",
                intro: "When the Quraysh tried to assassinate the Prophet ﷺ, Allah protected him and Abu Bakr (RA) in the Cave of Thawr. This moment became a symbol of companionship, courage, and total trust in Allah.",
                sections: [
                    StorySection(
                        isBullets: false,
                        heading: "The Journey Begins",
                        paragraphs: [
                            "Abu Bakr (RA) had prepared two camels for days, waiting for the Prophet ﷺ. When the Prophet ﷺ finally said, “Allah has given me permission to migrate,” Abu Bakr (RA) wept with joy and asked, “Will I be your companion?” The Prophet ﷺ said yes.",
                            "This was not an ordinary friendship. It was loyalty in the path of Allah."
                        ]
                    ),
                    StorySection(
                        isBullets: false,
                        heading: "In the Cave",
                        paragraphs: [
                            "The Quraysh sent trackers to hunt the Prophet ﷺ. The Prophet ﷺ and Abu Bakr (RA) hid in the Cave of Thawr.",
                            "When the enemies came so close that they could have just looked down and seen them, Abu Bakr (RA) whispered in fear — not for himself, but for the Prophet ﷺ.",
                            "The Prophet ﷺ replied: “Do not grieve. Indeed, Allah is with us.”"
                        ]
                    ),
                    StorySection(
                        isBullets: false,
                        heading: "Allah’s Protection",
                        paragraphs: [
                            "Allah covered the cave with signs that made it look untouched: a spider’s web across the entrance and a dove’s nest.",
                            "The pursuers turned back. The Prophet ﷺ and Abu Bakr (RA) were safe."
                        ]
                    ),
                    StorySection(
                        isBullets: true,
                        heading: "Lessons",
                        paragraphs: [
                            "Unshakable faith: Trust Allah even at the edge of danger.",
                            "Loyalty: Abu Bakr (RA) feared only for the safety of the Prophet ﷺ, not himself.",
                            "Allah’s power: A spider’s web defeated an army."
                        ]
                    ),
                    StorySection(
                        isBullets: false,
                        heading: "Legacy",
                        paragraphs: [
                            "This moment is immortalized in Qur’an 9:40. Believers remember these words in every moment of fear: “Do not grieve, indeed Allah is with us.”"
                        ]
                    )
                ]
            ),
            StoryArticle(
                title: "Freeing Bilal ibn Rabah (RA)",
                subtitle: "Compassion, Justice, and Brotherhood",
                intro: "Bilal (RA) was tortured in the blazing sun for saying 'Ahad, Ahad' — 'Allah is One.' Abu Bakr (RA) freed him, not as an act of charity, but as an act of justice and love for a believer.",
                sections: [
                    StorySection(
                        isBullets: false,
                        heading: "The Torture of Bilal",
                        paragraphs: [
                            "Bilal (RA) was chained on the hot desert ground with a massive stone on his chest. His master tried to force him to reject Islam.",
                            "But Bilal kept saying, 'Ahad, Ahad' — declaring that Allah is One."
                        ]
                    ),
                    StorySection(
                        isBullets: false,
                        heading: "Abu Bakr Steps In",
                        paragraphs: [
                            "When Abu Bakr (RA) heard of this, he went to Bilal’s master and bought his freedom with his own money.",
                            "He told Bilal (RA), “You are free.”"
                        ]
                    ),
                    StorySection(
                        isBullets: false,
                        heading: "Brotherhood, Not Status",
                        paragraphs: [
                            "Bilal (RA) was not treated as ‘a freed slave.’ He was treated as a brother, equal in dignity.",
                            "Later, the Prophet ﷺ chose Bilal (RA) to be the first muezzin of Islam."
                        ]
                    ),
                    StorySection(
                        isBullets: true,
                        heading: "Lessons",
                        paragraphs: [
                            "Spend for justice, not ego.",
                            "Faith is stronger than torture.",
                            "Islam honors all races and backgrounds as equals."
                        ]
                    )
                ]
            ),
            StoryArticle(
                title: "The Night of Isra’ and Mi‘raj",
                subtitle: "How Abu Bakr (RA) Became 'As-Siddiq'",
                intro: "When the Prophet ﷺ told Quraysh about his miraculous journey to Jerusalem and the heavens, they mocked him. Abu Bakr (RA) did not hesitate for even a second.",
                sections: [
                    StorySection(
                        isBullets: false,
                        heading: "The Claim",
                        paragraphs: [
                            "The Prophet ﷺ described traveling from Makkah to Jerusalem and ascending through the heavens in one night.",
                            "The Quraysh ran to Abu Bakr (RA), hoping he would doubt the Prophet ﷺ."
                        ]
                    ),
                    StorySection(
                        isBullets: false,
                        heading: "The Response",
                        paragraphs: [
                            "They said, 'Do you hear what he claims?'",
                            "Abu Bakr (RA) asked, 'Did he say it?'",
                            "They said, 'Yes.'",
                            "He said, 'If he said it, then it is true.'",
                            "From that day, he was given the title As-Siddiq — 'The Truthful.'"
                        ]
                    ),
                    StorySection(
                        isBullets: true,
                        heading: "Lessons",
                        paragraphs: [
                            "Real iman is instant trust in Allah and His Messenger ﷺ.",
                            "Support truth even if people laugh at it.",
                            "Faith is not just belief — it’s loyalty."
                        ]
                    )
                ]
            ),
            StoryArticle(
                title: "The First Speech as Caliph",
                subtitle: "Leadership Built on Humility",
                intro: "After the passing of the Prophet ﷺ, Abu Bakr (RA) became the first Caliph. His first speech set the standard for Islamic leadership forever.",
                sections: [
                    StorySection(
                        isBullets: false,
                        heading: "The Ummah in Shock",
                        paragraphs: [
                            "After the Prophet ﷺ passed away, many companions were shattered. Some even denied that he had died.",
                            "Abu Bakr (RA) calmed the people with Qur’an 3:144 — reminding them that the Messenger ﷺ has returned to Allah, but the mission of Islam continues."
                        ]
                    ),
                    StorySection(
                        isBullets: false,
                        heading: "His First Address",
                        paragraphs: [
                            "He said: 'I have been appointed over you, though I am not the best among you. If I do right, help me; if I do wrong, correct me… Obey me as long as I obey Allah and His Messenger.'",
                            "He defined leadership as responsibility, not status."
                        ]
                    ),
                    StorySection(
                        isBullets: true,
                        heading: "Lessons",
                        paragraphs: [
                            "Leaders in Islam can be corrected.",
                            "Power is service, not privilege.",
                            "Obedience is only due while the leader obeys Allah."
                        ]
                    )
                ]
            ),
            StoryArticle(
                title: "The Compilation of the Qur’an",
                subtitle: "Protecting Revelation Forever",
                intro: "After the Battle of Yamamah, many memorizers of Qur’an were martyred. Umar (RA) urged Abu Bakr (RA) to compile the Qur’an into one book so nothing would be lost.",
                sections: [
                    StorySection(
                        isBullets: false,
                        heading: "The Crisis After Yamamah",
                        paragraphs: [
                            "Many Huffaz died in battle. Umar (RA) feared parts of the Qur’an could be lost if this continued.",
                            "He went to Abu Bakr (RA) and said: 'I fear a large part of the Qur’an may be lost.'"
                        ]
                    ),
                    StorySection(
                        isBullets: false,
                        heading: "Assigning Zayd ibn Thabit (RA)",
                        paragraphs: [
                            "Abu Bakr (RA) agreed — after deep reflection.",
                            "He assigned Zayd ibn Thabit (RA) to collect the Qur’an from every verified source: written pieces, bones, leather, and the memories of the companions.",
                            "This became the first Mushaf."
                        ]
                    ),
                    StorySection(
                        isBullets: true,
                        heading: "Lessons",
                        paragraphs: [
                            "Protecting the Qur’an is the highest priority.",
                            "Leadership means seeing danger early.",
                            "The preservation of Islam is a trust for all generations."
                        ]
                    )
                ]
            ),
            StoryArticle(
                title: "The Passing of the Prophet ﷺ",
                subtitle: "Abu Bakr (RA) Calms the Ummah",
                intro: "When the Prophet ﷺ passed away, chaos and heartbreak hit the Ummah. Abu Bakr (RA) reminded them that our worship is for Allah, who never dies.",
                sections: [
                    StorySection(
                        isBullets: false,
                        heading: "Shock in Madinah",
                        paragraphs: [
                            "Some companions could not accept the news. Umar (RA) even said, 'The Messenger of Allah has not died!'",
                            "Abu Bakr (RA) entered, kissed the forehead of the Prophet ﷺ, and said, 'You are pure in life and in death.'"
                        ]
                    ),
                    StorySection(
                        isBullets: false,
                        heading: "The Words That Saved the Ummah",
                        paragraphs: [
                            "He gathered the people and said: 'Whoever worshipped Muhammad — know that Muhammad has died. Whoever worships Allah — Allah is Ever-Living and never dies.'",
                            "Then he recited Qur’an 3:144, and the reality settled into every heart."
                        ]
                    ),
                    StorySection(
                        isBullets: true,
                        heading: "Lessons",
                        paragraphs: [
                            "Truth must lead emotion.",
                            "Leadership means anchoring people in faith during crisis.",
                            "Islam continues even after the Prophet ﷺ — it belongs to Allah."
                        ]
                    )
                ]
            ),
            StoryArticle(
                title: "Final Illness & Appointment of Umar (RA)",
                subtitle: "Securing Stability for the Ummah",
                intro: "Near the end of his life, Abu Bakr (RA) worried about the future of the Muslims. He ensured the Ummah would not break by appointing Umar (RA) as the next Caliph.",
                sections: [
                    StorySection(
                        isBullets: false,
                        heading: "Illness and Concern",
                        paragraphs: [
                            "Abu Bakr (RA) grew ill two years after becoming Caliph. Even while weak, he was thinking about unity and stability for the Ummah."
                        ]
                    ),
                    StorySection(
                        isBullets: false,
                        heading: "Consultation and Choice",
                        paragraphs: [
                            "He spoke to senior companions like Uthman (RA), Ali (RA), Abdur Rahman ibn Awf (RA).",
                            "They agreed that Umar ibn al-Khattab (RA) was most capable.",
                            "Some feared Umar (RA) was too strict. Abu Bakr (RA) said, 'He is only firm because he sees me soft. When he is responsible, he will become gentle.'"
                        ]
                    ),
                    StorySection(
                        isBullets: false,
                        heading: "The Will",
                        paragraphs: [
                            "Abu Bakr (RA) dictated the appointment of Umar (RA) as Caliph. The people accepted him.",
                            "Shortly after, Abu Bakr (RA) passed away at age 63 — the same age as the Prophet ﷺ. He was buried beside the Prophet ﷺ in Madinah."
                        ]
                    ),
                    StorySection(
                        isBullets: true,
                        heading: "Lessons",
                        paragraphs: [
                            "Leadership includes preparing after you.",
                            "He chose unity over chaos.",
                            "He left the world with humility — even asking for a simple burial cloth."
                        ]
                    )
                ]
            )
        ]
    }

    // TODO: Add Umar (RA), Uthman (RA), Ali (RA) data here.
    // We'll scaffold them now.
    private var umarStories: [StoryArticle] { [] }
    private var uthmanStories: [StoryArticle] { [] }
    private var aliStories: [StoryArticle] { [] }

    // MARK: Caliphs list

    func allCaliphs() -> [Caliph] {
        [
            Caliph(
                order: 1,
                name: "Abu Bakr (RA)",
                title: "As-Siddiq · First Caliph",
                stories: abuBakrStories
            ),
            Caliph(
                order: 2,
                name: "Umar ibn al-Khattab (RA)",
                title: "Al-Faruq · Second Caliph",
                stories: umarStories
            ),
            Caliph(
                order: 3,
                name: "Uthman ibn Affan (RA)",
                title: "Dhun-Nurayn · Third Caliph",
                stories: uthmanStories
            ),
            Caliph(
                order: 4,
                name: "Ali ibn Abi Talib (RA)",
                title: "Lion of Allah · Fourth Caliph",
                stories: aliStories
            )
        ]
    }

    func caliph(withName name: String) -> Caliph? {
        return allCaliphs().first { $0.name == name }
    }
}
