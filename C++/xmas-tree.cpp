#include <iostream>

using namespace std;

int main()
{
    int i, j, lines;
    cout << "Pleasae enter a number " << endl;
    cin >> lines;
    cin.ignore();

    for (j=l; j<=lines * 2; j=j+2)
    {
        for (i=j; i<=lines*2-2; i=i+2)
        {
            cout << " ";
        }    
        for (i=1; i<=j; i++)
        {
            cout << "*";
        }    
        cout << endl;
    }
    cin.ignore();
}