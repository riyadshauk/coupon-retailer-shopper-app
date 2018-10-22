// interface ShopperPreferencesRequest {
//     // various shopper preferences...
//     jeans: Boolean;
//     shirts: Boolean;
//     longsleeve: Boolean;
//     shortsleeve: Boolean;
//     computers: Boolean;
//     videogames: Boolean;
//     sports: Boolean;
// }

const shopperPrefs = () => {
    const categories = [
        'jeans',
        'shirts',
        'longsleeve',
        'shortsleeve',
        'computers',
        'videogames',
        'sports',
    ];
    return categories.reduce((o, c) => {
        o[c] = Math.random() < 0.5 ? true : false;
        return o;
    }, {});
};
export default shopperPrefs;