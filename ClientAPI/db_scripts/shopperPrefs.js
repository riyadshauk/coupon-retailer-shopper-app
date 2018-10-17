// interface ShopperPreferencesRequest {
//     /// Reference to shopper that owns this ShopperPreferences.
//     shopperID: Number; /* Get this from the callback passed to loginShopper */
    
//     // various shopper preferences...
//     jeans: Boolean;
//     shirts: Boolean;
//     longsleeve: Boolean;
//     shortsleeve: Boolean;
//     computers: Boolean;
//     videogames: Boolean;
//     sports: Boolean;
// }

const shopperPrefs = [
    {
        shopperID: 1,
        jeans: false,
        shirts: false,
        longsleeve: false,
        shortsleeve: true,
        computers: true,
        videogames: true,
        sports: true,
    },
    {
        // etc
    },
]
export default shopperPrefs;