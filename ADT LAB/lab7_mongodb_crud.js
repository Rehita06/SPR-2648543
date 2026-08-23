// ============================================================
// LAB - 7 : MONGODB CRUD OPS
// Demonstration of CRUD operations and Aggregate functions in MongoDB
// Database: canteendb
//
// HOW TO RUN:
//   mongosh "mongodb://localhost:27017" lab7_mongodb_crud.js
// or paste the contents into an interactive mongosh session.
//
// NOTE: `use canteendb` and `show collections` are interactive-shell
// helpers, not valid JavaScript, so they will throw a SyntaxError if
// this file is run in script mode (mongosh file.js) or loaded via
// load(). This version uses db.getSiblingDB(), which works in BOTH
// interactive mode and script mode, and is guaranteed to parse.
// ============================================================

db = db.getSiblingDB("canteendb");

// ------------------------------------------------------------
// 1. CREATE OPERATIONS
// ------------------------------------------------------------

// Create collections
db.createCollection("users");
db.createCollection("vendors");
db.createCollection("menu_items");
db.createCollection("orders");
db.createCollection("order_items");

print(db.getCollectionNames());

// insertOne() - inserts a single document
db.users.insertOne(
    { userId: 1, name: "Rehita", email: "rehita@gmail.com", userType: "Student", phone: "9876543210" }
);

// insertMany() - inserts multiple documents
db.users.insertMany([
    { userId: 2, name: "Rahul", email: "rahul@gmail.com", userType: "Student", phone: "9876543211" },
    { userId: 3, name: "Anu", email: "anu@gmail.com", userType: "Faculty", phone: "9876543212" },
    { userId: 4, name: "Kiran", email: "kiran@gmail.com", userType: "Student", phone: "9876543213" },
    { userId: 5, name: "Priya", email: "priya@gmail.com", userType: "Staff", phone: "9876543214" }
]);

db.vendors.insertMany([
    { vendorId: 101, vendorName: "Food Corner", contactNo: "9874563217", location: "Block A", openingTime: "08:00", closingTime: "20:00" },
    { vendorId: 102, vendorName: "Juice Point", contactNo: "9000000002", location: "Block B", openingTime: "09:00", closingTime: "18:00" },
    { vendorId: 103, vendorName: "South Meals", contactNo: "9000000003", location: "Block C", openingTime: "07:00", closingTime: "21:00" },
    { vendorId: 104, vendorName: "Pizza Hub", contactNo: "9000000004", location: "Block D", openingTime: "10:00", closingTime: "22:00" },
    { vendorId: 105, vendorName: "Tea Stall", contactNo: "9000000005", location: "Block E", openingTime: "06:00", closingTime: "19:00" }
]);

db.menu_items.insertMany([
    { itemId: 201, itemName: "Samosa", price: 20, availabilityStatus: true, prepTime: 5 },
    { itemId: 202, itemName: "Tea", price: 15, availabilityStatus: true, prepTime: 2 },
    { itemId: 203, itemName: "Meals", price: 120, availabilityStatus: true, prepTime: 15 },
    { itemId: 204, itemName: "Pizza", price: 150, availabilityStatus: true, prepTime: 20 },
    { itemId: 205, itemName: "Juice", price: 60, availabilityStatus: true, prepTime: 5 }
]);

db.orders.insertMany([
    { orderId: 301, userId: 1, vendorId: 101, orderStatus: "Delivered", orderTime: "10:00", predictedReadyTime: "10:10", pickupTime: "10:12", totalAmount: 40, qrCode: "QR301" },
    { orderId: 302, userId: 2, vendorId: 102, orderStatus: "Pending",   orderTime: "11:00", predictedReadyTime: "11:08", pickupTime: null,    totalAmount: 60, qrCode: "QR302" },
    { orderId: 303, userId: 3, vendorId: 103, orderStatus: "Delivered", orderTime: "12:00", predictedReadyTime: "12:20", pickupTime: "12:18", totalAmount: 120, qrCode: "QR303" },
    { orderId: 304, userId: 4, vendorId: 104, orderStatus: "Cancelled", orderTime: "13:00", predictedReadyTime: "13:25", pickupTime: null,    totalAmount: 180, qrCode: "QR304" },
    { orderId: 305, userId: 5, vendorId: 105, orderStatus: "Delivered", orderTime: "14:00", predictedReadyTime: "14:05", pickupTime: "14:06", totalAmount: 45, qrCode: "QR305" }
]);

// ------------------------------------------------------------
// 2. READ OPERATIONS
// ------------------------------------------------------------

// find() -> returns all matching documents (use .toArray() in scripts
// so the cursor is fully materialized/printed)
print(db.users.find().toArray());

// findOne() -> returns the first matching document
print(db.orders.findOne({ orderId: 301 }));

print(db.menu_items.find({ availabilityStatus: true }).toArray());

// ------------------------------------------------------------
// 3. LOGICAL OPERATORS: $and, $or, $not, $nor
// ------------------------------------------------------------

// $and - both conditions must be true
print(db.orders.find({
    $and: [
        { orderStatus: "Delivered" },
        { totalAmount: { $gt: 50 } }
    ]
}).toArray());

// $or - either condition can be true
print(db.orders.find({
    $or: [
        { orderStatus: "Pending" },
        { orderStatus: "Cancelled" }
    ]
}).toArray());

// $nor - documents that match NEITHER condition (neither Pending nor Cancelled)
print(db.orders.find({
    $nor: [
        { orderStatus: "Pending" },
        { orderStatus: "Cancelled" }
    ]
}).toArray());

// $not - price NOT greater than 100
print(db.menu_items.find({
    price: { $not: { $gt: 100 } }
}).toArray());

// ------------------------------------------------------------
// 4. RELATIONAL OPERATORS: $gt, $lt, $eq, $ne, $gte, $lte, $in, $nin
// ------------------------------------------------------------

print(db.menu_items.find({ price: { $gt: 50 } }).toArray());
print(db.menu_items.find({ price: { $lt: 100 } }).toArray());
print(db.orders.find({ orderStatus: { $eq: "Delivered" } }).toArray());
print(db.orders.find({ orderStatus: { $ne: "Delivered" } }).toArray());
print(db.menu_items.find({ price: { $gte: 60 } }).toArray());
print(db.menu_items.find({ price: { $lte: 60 } }).toArray());
print(db.orders.find({ vendorId: { $in: [101, 103] } }).toArray());
print(db.orders.find({ vendorId: { $nin: [101, 103] } }).toArray());

// ------------------------------------------------------------
// 5. UPDATE OPERATIONS
// ------------------------------------------------------------

// updateOne() - modify a single document's field
db.orders.updateOne(
    { orderId: 302 },
    { $set: { orderStatus: "Delivered" } }
);

// updateMany() - modify multiple documents (increment price by 5
// for all available items)
db.menu_items.updateMany(
    { availabilityStatus: true },
    { $inc: { price: 5 } }
);

// ------------------------------------------------------------
// 6. DELETE OPERATIONS
// ------------------------------------------------------------

// First insert a demo order_item so deleteOne() has something real
// to delete (the manual references orderItemId:405 without ever
// showing it being inserted).
db.order_items.insertOne({ orderItemId: 405, orderId: 304, itemId: 204, quantity: 1, unitPrice: 155, subtotal: 155 });

// deleteOne() - deletes only one matching document
db.order_items.deleteOne({ orderItemId: 405 });

// deleteMany() - deletes all cancelled orders
db.orders.deleteMany({ orderStatus: "Cancelled" });

// ------------------------------------------------------------
// 7. AGGREGATION OPERATIONS
// $match, $group, $sum, $avg, $count, $project, $sort, $unwind, $lookup
// ------------------------------------------------------------

// $match - filter documents (similar to WHERE clause)
print(db.orders.aggregate([
    { $match: { orderStatus: "Delivered" } }
]).toArray());

// $group + $sum - total sales grouped by vendor
print(db.orders.aggregate([
    { $group: { _id: "$vendorId", totalSales: { $sum: "$totalAmount" } } }
]).toArray());

// $avg - average order amount across all orders
print(db.orders.aggregate([
    { $group: { _id: null, averageAmount: { $avg: "$totalAmount" } } }
]).toArray());

// $count - total number of order documents
print(db.orders.aggregate([
    { $count: "TotalOrders" }
]).toArray());

// $project - reshape output, showing only selected fields
print(db.orders.aggregate([
    { $project: { _id: 0, orderId: 1, vendorId: 1, totalAmount: 1 } }
]).toArray());

// $sort - order documents by totalAmount descending
print(db.orders.aggregate([
    { $sort: { totalAmount: -1 } }
]).toArray());

// $unwind - split an array field into separate documents
db.orders.updateOne(
    { orderId: 301 },
    { $set: { addons: ["Sauce", "Chutney"] } }
);

print(db.orders.aggregate([
    { $match: { orderId: 301 } },
    { $unwind: "$addons" }
]).toArray());

// $lookup - join documents from another collection (like SQL JOIN)
print(db.orders.aggregate([
    {
        $lookup: {
            from: "vendors",
            localField: "vendorId",
            foreignField: "vendorId",
            as: "vendorDetails"
        }
    }
]).toArray());
